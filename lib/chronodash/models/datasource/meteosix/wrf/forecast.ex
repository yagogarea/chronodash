defmodule Chronodash.Models.DataSource.MeteoSIX.WRF.Forecast do
  @moduledoc """
  Parser for MeteoSIX WRF Forecast data.
  Converts raw MeteoSIX JSON into standardized ObservationData structs.
  """
  alias Chronodash.Metrics.ObservationData

  @doc """
  Parses a MeteoSIX response into a list of ObservationData.
  """
  def to_observation_data(response, metric_type) do
    case response["features"] do
      [feature | _] ->
        coords = extract_coords(feature["geometry"])
        name = feature["properties"]["name"] || default_name(coords)
        days = feature["properties"]["days"] || []

        parse_days(days, name, coords, metric_type)

      _ ->
        []
    end
  end

  defp parse_days(days, location_name, coords, metric_type) do
    Enum.flat_map(days, &process_day(&1, location_name, coords, metric_type))
  end

  defp process_day(day, location_name, coords, metric_type) do
    case Enum.find(day["variables"], fn v -> v["name"] == to_string(metric_type) end) do
      nil -> []
      variable -> process_variable(variable, location_name, coords, metric_type)
    end
  end

  defp process_variable(variable, location_name, coords, metric_type) do
    Enum.flat_map(variable["values"], fn val ->
      timestamp = parse_timestamp(val["timeInstant"])
      extract_metrics(val, variable, metric_type, location_name, coords, timestamp)
    end)
  end

  # Special handling for composite variables (Wind)
  defp extract_metrics(val, variable, :wind, name, coords, ts) do
    [
      build_base(
        name,
        coords,
        "wind_module",
        val["moduleValue"],
        variable["moduleUnits"],
        ts,
        val
      ),
      build_base(
        name,
        coords,
        "wind_direction",
        val["directionValue"],
        variable["directionUnits"],
        ts,
        val
      )
    ]
  end

  # Default handling for simple variables
  defp extract_metrics(val, variable, metric_type, name, coords, ts) do
    [
      build_base(name, coords, to_string(metric_type), val["value"], variable["units"], ts, val)
    ]
  end

  defp build_base(name, {lat, lon}, type, val, unit, ts, raw) do
    %ObservationData{
      location_name: name,
      latitude: lat,
      longitude: lon,
      metric_type: type,
      value: normalize_value(val),
      unit: unit,
      timestamp: ts,
      source: "meteosix",
      metadata: %{original_value: val, raw_payload: raw}
    }
  end

  defp normalize_value(v) when is_number(v), do: v * 1.0

  defp normalize_value(v) when is_binary(v) do
    cond do
      Regex.match?(~r/^-?\d+(\.\d+)?$/, v) ->
        {f, _} = Float.parse(v)
        f

      # Sky States
      v == "SUNNY" ->
        1.0

      v == "PARTLY_CLOUDY" ->
        2.0

      v == "HIGH_CLOUDS" ->
        3.0

      v == "CLOUDY" ->
        4.0

      v == "OVERCAST" ->
        5.0

      true ->
        0.0
    end
  end

  defp normalize_value(_), do: 0.0

  defp extract_coords(%{"coordinates" => [lon, lat]}), do: {lat, lon}
  defp extract_coords(_), do: {0.0, 0.0}

  defp default_name({lat, lon}), do: "#{lat}, #{lon}"
  defp default_name(_), do: "Unknown Location"

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(time_str) do
    case DateTime.from_iso8601(time_str) do
      {:ok, dt, _} ->
        dt

      _ ->
        case DateTime.from_iso8601(time_str <> "Z") do
          {:ok, dt, _} -> dt
          _ -> nil
        end
    end
  end
end
