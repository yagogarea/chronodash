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

defmodule Chronodash.HttpClient.Finch do
  @moduledoc """
  Finch-based implementation of the `Chronodash.HttpClient` behaviour.
  """
  @behaviour Chronodash.HttpClient

  @finch_name Chronodash.Finch

  # ============================================================================
  # Public API
  # ============================================================================

  def get(url, headers \\ [], opts \\ []) do
    do_request(:get, url, headers, nil, opts)
  end

  def post(url, body, headers \\ [], opts \\ []) do
    do_request(:post, url, headers, body, opts)
  end

  def request(method, url, headers \\ [], body \\ nil, opts \\ []) do
    do_request(method, url, headers, body, opts)
  end

  # ============================================================================
  # Helper functions
  # ============================================================================

  defp do_request(method, url, headers, body, opts) do
    req_opts = [
      method: method,
      url: url,
      headers: headers,
      body: body,
      finch: @finch_name
    ]

    # Combine with provided options
    final_opts = Keyword.merge(req_opts, opts)

    case Req.request(final_opts) do
      {:ok, %Req.Response{status: status, body: body}} ->
        {:ok, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
