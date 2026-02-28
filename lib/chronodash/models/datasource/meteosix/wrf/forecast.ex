defmodule Chronodash.Models.DataSource.MeteoSIX.WRF.Forecast do
  @moduledoc """
  DTO for MeteoSIX WRF Forecast data.
  """
  defstruct [
    :location_name,
    :coords,
    :metric_type,
    # List of %{timestamp: DateTime.t(), value: any()}
    :values
  ]

  @type t :: %__MODULE__{
          location_name: String.t(),
          coords: {float(), float()},
          metric_type: atom(),
          values: list(%{timestamp: DateTime.t(), value: any()})
        }

  @doc """
  Parses a MeteoSIX response into a Forecast DTO.
  """
  def new(response, metric_type) do
    case response["features"] do
      [feature | _] ->
        %__MODULE__{
          location_name: feature["properties"]["name"],
          coords: extract_coords(feature["geometry"]),
          metric_type: metric_type,
          values: parse_values(feature["properties"]["days"], metric_type)
        }

      _ ->
        {:error, :no_data}
    end
  end

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
