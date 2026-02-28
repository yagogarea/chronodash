defmodule Chronodash.DataSource.MeteoSIX.Tides do
  @moduledoc """
  High-level service for fetching Tides info from MeteoSIX.
  """
  alias MeteoSIX.Operations
  alias Chronodash.Models.DataSource.MeteoSIX.TidesForecast

  @doc """
  Fetches tidal info from MeteoSIX and parses it into a DTO.
  """
  def get_tides_info(id_or_coords, opts \\ []) do
    case Operations.get_tides_info(id_or_coords, opts) do
      {:ok, response} -> TidesForecast.new(response)
      {:error, reason} -> {:error, reason}
    end
  end
end
