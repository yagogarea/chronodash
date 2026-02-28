defmodule Chronodash.DataSource.MeteoSIX.WRF do
  @moduledoc """
  High-level service for fetching WRF Forecast from MeteoSIX.
  """
  alias Chronodash.Models.DataSource.MeteoSIX.WRF.Forecast
  alias MeteoSIX.WRF

  @doc """
  Fetches forecast from MeteoSIX and returns a list of standardized ObservationData structs.
  """
  def get_forecast(id_or_coords, var_atom, opts \\ []) do
    case WRF.get_forecast(id_or_coords, var_atom, opts) do
      {:ok, response} ->
        {:ok, Forecast.to_observation_data(response, var_atom)}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
