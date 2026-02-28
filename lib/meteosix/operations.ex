defmodule MeteoSIX.Operations do
  @moduledoc """
  Handles operations for MeteoSIX API endpoints
  """
  alias MeteoSIX

  @doc """
  Finds places by name using MeteoSIX's '/findPlaces' endpoint.
  """
  def find_places(query, opts \\ []) do
    params = [
      location: query,
      types: opts[:types],
      lang: opts[:lang] || "gl"
    ]

    MeteoSIX.request("findPlaces", params, opts)
  end

  @doc """
  Returns tidal information for the nearest port on the Galician coast.
  """
  def get_tides_info(location, opts \\ []) do
    params =
      location_params(location) ++
        [
          startTime: opts[:start_time],
          endTime: opts[:end_time],
          lang: opts[:lang] || "gl",
          tz: opts[:tz] || "Europe/Madrid"
        ]

    MeteoSIX.request("getTidesInfo", params, opts)
  end

  @doc """
  Returns sunrise, midday, sunset and daylight duration for any point on Earth.
  """
  def get_solar_info(location, opts \\ []) do
    params =
      location_params(location) ++
        [
          startTime: opts[:start_time],
          endTime: opts[:end_time],
          lang: opts[:lang] || "gl",
          tz: opts[:tz] || "Europe/Madrid"
        ]

    MeteoSIX.request("getSolarInfo", params, opts)
  end

  defp location_params({lat, lon}), do: [coords: "#{lon},#{lat}"]
  defp location_params(location_id), do: [locationIds: location_id]
end
