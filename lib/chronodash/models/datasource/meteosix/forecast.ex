defmodule Chronodash.Models.DataSource.MeteoSIX.Forecast do
  @moduledoc """
  DTO for MeteoSIX WRF and USWAN Forecast data.
  """
  defstruct [
    :location_name,
    :coords,
    :metric_type,
<<<<<<< HEAD
    # List of %{timestamp: DateTime.t(), metrics: [%{name: String.t(), value: any(), unit: String.t()}]}
    :points
  ]

  @type metric_entry :: %{name: String.t(), value: any(), unit: String.t() | nil}
  @type point :: %{timestamp: DateTime.t(), metrics: list(metric_entry())}

=======
    # List of %{timestamp: DateTime.t(), value: any()}
    :values
  ]

>>>>>>> 60e6998 (feat: implement USWAN forecast service and DTO for MeteoSIX)
  @type t :: %__MODULE__{
          location_name: String.t(),
          coords: {float(), float()},
          metric_type: atom(),
<<<<<<< HEAD
          points: list(point())
=======
          values: list(%{timestamp: DateTime.t(), value: any()})
>>>>>>> 60e6998 (feat: implement USWAN forecast service and DTO for MeteoSIX)
        }

  @doc """
  Parses a MeteoSIX response into a Forecast DTO.
  """
  def new(response, metric_type) do
    case response["features"] do
      [feature | _] ->
<<<<<<< HEAD
        coords = extract_coords(feature["geometry"])
        name = feature["properties"]["name"] || default_name(coords)

        %__MODULE__{
          location_name: name,
          coords: coords,
          metric_type: metric_type,
          points: parse_points(feature["properties"]["days"], metric_type)
=======
        %__MODULE__{
          location_name: feature["properties"]["name"],
          coords: extract_coords(feature["geometry"]),
          metric_type: metric_type,
          values: parse_values(feature["properties"]["days"], metric_type)
>>>>>>> 60e6998 (feat: implement USWAN forecast service and DTO for MeteoSIX)
        }

      _ ->
        {:error, :no_data}
    end
  end

<<<<<<< HEAD
  defp default_name({lat, lon}), do: "#{lat}, #{lon}"
  defp default_name(_), do: "Unknown Location"

  defp extract_coords(%{"coordinates" => [lon, lat]}), do: {lat, lon}
  defp extract_coords(_), do: {0.0, 0.0}

  defp parse_points(days, metric_type) when is_list(days) do
    Enum.flat_map(days, &process_forecast_day(&1, metric_type))
  end

  defp parse_points(_, _), do: []

  defp process_forecast_day(day, metric_type) do
    case Enum.find(day["variables"], fn v -> v["name"] == to_string(metric_type) end) do
      nil -> []
      variable -> map_values_to_points(variable, metric_type)
    end
  end

  defp map_values_to_points(variable, metric_type) do
    Enum.map(variable["values"], fn val ->
      %{
        timestamp: parse_timestamp(val["timeInstant"]),
        metrics: extract_metrics(val, variable, metric_type)
      }
    end)
  end

  # Special handling for composite variables
  defp extract_metrics(val, variable, :wind) do
    [
      %{
        name: "wind_module",
        value: val["moduleValue"],
        unit: variable["moduleUnits"]
      },
      %{
        name: "wind_direction",
        value: val["directionValue"],
        unit: variable["directionUnits"]
      }
    ]
  end

  # Default handling for simple variables
  defp extract_metrics(val, variable, metric_type) do
    [
      %{
        name: to_string(metric_type),
        value: val["value"],
        unit: variable["units"]
      }
    ]
  end
=======
  defp extract_coords(%{"coordinates" => [lon, lat]}), do: {lat, lon}
  defp extract_coords(_), do: nil

  defp parse_values(days, metric_type) when is_list(days) do
    Enum.flat_map(days, fn day ->
      # Find the variable in this day
      variable = Enum.find(day["variables"], fn v -> v["name"] == to_string(metric_type) end)

      if variable do
        Enum.map(variable["values"], fn val ->
          %{
            timestamp: parse_timestamp(val["timeInstant"]),
            value: val["value"]
          }
        end)
      else
        []
      end
    end)
  end

  defp parse_values(_, _), do: []
>>>>>>> 60e6998 (feat: implement USWAN forecast service and DTO for MeteoSIX)

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
