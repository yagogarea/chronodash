defmodule Chronodash.DataSource.MeteoSIX.Solar do
  @moduledoc """
  High-level service for fetching Solar info from MeteoSIX.
  """
  alias MeteoSIX.Operations
  alias Chronodash.Models.DataSource.MeteoSIX.SolarForecast

  @doc """
  Fetches solar info from MeteoSIX and parses it into a DTO.
  """
  def get_solar_info(id_or_coords, opts \\ []) do
    case Operations.get_solar_info(id_or_coords, opts) do
      {:ok, response} -> SolarForecast.new(response)
      {:error, reason} -> {:error, reason}
    end
  end
end
