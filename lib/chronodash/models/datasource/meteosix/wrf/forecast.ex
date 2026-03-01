# Elixir backend that analyzes meteoFIX data, provides insights, and integrates with Grafana.

# Copyright (C) 2026 Santiago Garea Cidre, Paula Carril Gontán, and Saúl Zas Carballal

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).

defmodule Chronodash.Models.DataSource.MeteoSIX.WRF.Forecast do
  @moduledoc """
  DTO for MeteoSIX WRF Forecast data.
  Handles both simple and composite metrics (like wind).
  """
  defstruct [
    :location_name,
    :coords,
    :metric_type,
    # List of %{timestamp: DateTime.t(), metrics: [%{name: String.t(), value: any(), unit: String.t()}]}
    :points
  ]

  @type metric_entry :: %{name: String.t(), value: any(), unit: String.t() | nil}
  @type point :: %{timestamp: DateTime.t(), metrics: list(metric_entry())}

  @type t :: %__MODULE__{
          location_name: String.t(),
          coords: {float(), float()},
          metric_type: atom(),
          points: list(point())
        }

  @doc """
  Parses a MeteoSIX response into a Forecast DTO.
  """
  def new(response, metric_type) do
    case response["features"] do
      [feature | _] ->
        coords = extract_coords(feature["geometry"])
        name = feature["properties"]["name"] || default_name(coords)

        %__MODULE__{
          location_name: name,
          coords: coords,
          metric_type: metric_type,
          points: parse_points(feature["properties"]["days"], metric_type)
        }

      _ ->
        {:error, :no_data}
    end
  end

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
