defmodule MeteoSIX.WRF do
  @moduledoc """
  Handles WRF model numeric forecast info from MeteoSIX.
  """
  alias MeteoSIX

  @type vars ::
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
