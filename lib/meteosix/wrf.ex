defmodule MeteoSIX.WRF do
  @moduledoc """
  Handles WRF model numeric forecast info from MeteoSIX.
  """
  alias MeteoSIX

  @type vars :: [
          :sky_state
          | :temperature
          | :precipitation_amount
          | :wind
          | :relative_humidity
          | :cloud_area_fraction
          | :air_pressure_at_sea_level
          | :snow_level
        ]

  @doc """
  Gets numeric forecast info (WRF model).
  """
  def get_forecast(coords, var, opts \\ [])

  def get_forecast({lat, lon}, var, opts) do
    params = [
      coords: "#{lat},#{lon}",
      variables: var,
      models: opts[:models] || "WRF",
      grids: opts[:grids] || "1km",
      startTime: opts[:startTime],
      endTime: opts[:endTime],
      lang: opts[:lang] || "gl",
      tz: opts[:tz] || "Europe/Madrid",
      autoAdjustPosition: "true"
    ]

    MeteoSIX.request("getNumericForecastInfo", params, opts)
  end

  def get_forecast(location_id, var, opts) do
    params = [
      locationIds: location_id,
      variables: var,
      models: opts[:models] || "WRF",
      grids: opts[:grids] || "1km",
      startTime: opts[:startTime],
      endTime: opts[:endTime],
      lang: opts[:lang] || "gl",
      tz: opts[:tz] || "Europe/Madrid",
      autoAdjustPosition: "true"
    ]

    MeteoSIX.request("getNumericForecastInfo", params, opts)
  end
end
