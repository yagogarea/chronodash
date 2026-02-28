defmodule MeteoSIX.USWAN do
  @moduledoc """
  Handles USWAN model numeric forecast info from MeteoSIX.
  """
  alias MeteoSIX

  @type vars ::
          :significative_wave_height

  @var_mapping %{
    significative_wave_height: "significative_wave_height",
  }

  @doc """
  Gets numeric forecast info (USWAN model).
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
      models: "USWAN",
      grids: opts[:grids] || "Galicia",
      units: opts[:units],
      startTime: opts[:startTime],
      endTime: opts[:endTime],
      lang: opts[:lang] || "gl",
      tz: opts[:tz] || "Europe/Madrid",
      autoAdjustPosition: "true"
    ]
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end
end
