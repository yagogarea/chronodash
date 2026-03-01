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

defmodule Chronodash.HttpClient.Mock do
  @behaviour Chronodash.HttpClient

  def get(_url, _headers, _opts) do
    {:ok, %{status: 200, body: %{"features" => []}}}
  end

  def post(_url, _body, _headers, _opts) do
    {:ok, %{status: 201, body: %{"status" => "created"}}}
  end

  def request(method, _url, _headers, _body, _opts) do
    case method do
      :get -> {:ok, %{status: 200, body: %{"features" => []}}}
      :post -> {:ok, %{status: 201, body: %{"status" => "created"}}}
      _ -> {:ok, %{status: 200, body: %{"features" => []}}}
    end
  end
end
