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

defmodule Chronodash.HttpClient do
  @moduledoc """
  Behaviour for HTTP clients.
  """

  @http_client Application.compile_env(
                 :chronodash,
                 :http_client,
                 Chronodash.HttpClient.Finch
               )

  # ============================================================================
  # Callbacks
  # ============================================================================

  @callback get(url :: String.t(), headers :: list(), opts :: keyword()) ::
              {:ok, %{status: integer(), body: any()}} | {:error, any()}

  @callback post(url :: String.t(), body :: any(), headers :: list(), opts :: keyword()) ::
              {:ok, %{status: integer(), body: any()}} | {:error, any()}

  @callback request(
              method :: atom(),
              url :: String.t(),
              headers :: list(),
              body :: any(),
              opts :: keyword()
            ) ::
              {:ok, %{status: integer(), body: any()}} | {:error, any()}

  # ============================================================================
  # Public API
  # ============================================================================

  def get(url, headers \\ [], opts \\ []) do
    impl().get(url, headers, with_defaults(opts))
  end

  def post(url, body, headers \\ [], opts \\ []) do
    impl().post(url, body, headers, with_defaults(opts))
  end

  def request(method, url, headers \\ [], body \\ nil, opts \\ []) do
    impl().request(method, url, headers, body, with_defaults(opts))
  end

  # ============================================================================
  # Private API
  # ============================================================================

  defp impl, do: @http_client

  defp with_defaults(opts) do
    default_opts = Application.get_env(:chronodash, :http_client_default_opts, [])
    Keyword.merge(default_opts, opts)
  end
end
