defmodule MeteoSIX.Operations do
  @moduledoc """
  Handles location-related operations for MeteoSIX.
  """
  alias MeteoSIX

  @doc """
  Finds places by name using MeteoSIX's findPlaces endpoint.
  """
  def find_places(query, opts \\ []) do
    params = [
      location: query,
      types: opts[:types],
      lang: opts[:lang] || "gl"
    ]

    MeteoSIX.request("findPlaces", params, opts)
  end
end
