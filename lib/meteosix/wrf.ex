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

defmodule MeteoSIX.WRF do
  @moduledoc """
  Handles WRF model numeric forecast info from MeteoSIX.
  """
  alias MeteoSIX

  @type variable ::
          :sky_state
          | :temperature
          | :precipitation_amount
          | :wind
          | :relative_humidity
          | :cloud_area_fraction
          | :air_pressure_at_sea_level
          | :snow_level

  @var_mapping %{
    sky_state: "sky_state",
    temperature: "temperature",
    precipitation_amount: "precipitation_amount",
    wind: "wind",
    relative_humidity: "relative_humidity",
    cloud_area_fraction: "cloud_area_fraction",
    air_pressure_at_sea_level: "air_pressure_at_sea_level",
    snow_level: "snow_level"
  }

  @doc """
  Gets numeric forecast info (WRF model).
  """
  def get_forecast(id_or_coords, var_atom, opts \\ [])

  def get_forecast({lat, lon}, var, opts) do
    params =
      [
        coords: "#{lon},#{lat}",
        variables: Map.get(@var_mapping, var, to_string(var))
      ]
      |> Keyword.merge(default_params(opts))

    MeteoSIX.request("getNumericForecastInfo", params, opts)
  end

  def get_forecast(location_id, var, opts)
      when is_binary(location_id) or is_integer(location_id) do
    params =
      [
        locationIds: location_id,
        variables: Map.get(@var_mapping, var, to_string(var))
      ]
      |> Keyword.merge(default_params(opts))

    MeteoSIX.request("getNumericForecastInfo", params, opts)
  end

  defp default_params(opts) do
    [
      models: opts[:models] || "WRF",
      grids: opts[:grids] || "1km",
      startTime: opts[:startTime],
      endTime: opts[:endTime],
      lang: opts[:lang] || "gl",
      tz: opts[:tz] || "Europe/Madrid",
      autoAdjustPosition: "true"
    ]
  end
end
