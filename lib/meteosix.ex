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

defmodule MeteoSIX do
  @moduledoc """
  Base module for MeteoSIX API v5 integration.
  Provides shared configuration and request logic.
  """
  alias Chronodash.HttpClient

  require Logger

  def config do
    Application.get_env(:chronodash, :meteosix)
  end

  def base_url, do: config()[:base_url]
  def api_key, do: config()[:api_key]

  @doc """
  Performs a GET request to MeteoSIX with common parameters.
  """
  def request(endpoint, params \\ [], opts \\ []) do
    url = "#{base_url()}/#{endpoint}"

    common_params = [
      API_KEY: api_key(),
      format: "application/json",
      exceptionsFormat: "application/json"
    ]

    final_params =
      common_params
      |> Keyword.merge(params)
      |> Enum.reject(fn {_, v} -> is_nil(v) end)

    response = HttpClient.get(url, [], Keyword.put(opts, :params, final_params))

    Logger.info("MeteoSIX Response: #{inspect(response)}")
    parse_request(response)
  end

  defp parse_request({:ok, %{status: 200, body: %{"exception" => %{"message" => msg}}}}) do
    {:error, "MeteoSIX Exception: #{msg}"}
  end

  defp parse_request({:ok, %{status: 200, body: data}}), do: {:ok, data}

  defp parse_request({:ok, %{status: status, body: body}}),
    do: {:error, "HTTP #{status}: #{body}"}

  defp parse_request({:error, %{message: message}}),
    do: {:error, message}

  defp parse_request({:error, reason}), do: {:error, reason}
end
