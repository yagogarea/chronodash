defmodule Chronodash.DataSource.MeteoSIX.WRF do
  @moduledoc """
  High-level service for fetching WRF Forecast from MeteoSIX.
  """
  alias MeteoSIX.WRF
  alias Chronodash.Models.DataSource.MeteoSIX.Forecast

  @doc """
  Fetches forecast from MeteoSIX and parses it into a DTO.
  """
  def get_forecast(id_or_coords, var_atom, opts \\ []) do
    case WRF.get_forecast(id_or_coords, var_atom, opts) do
      {:ok, response} ->
        case Forecast.new(response, var_atom) do
          %Forecast{} = forecast -> {:ok, forecast}
          {:error, _} = error -> error
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
