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

defmodule Chronodash.Alerting.Providers.Discord do
  @moduledoc """
  Discord implementation for alert delivery.

  Expects a configuration map with:
    - `:url` - The Discord webhook URL to send messages to.
  """

  @behaviour Chronodash.Alerting.Provider
  require Logger

  @impl true
  def deliver(message, %{url: url}) when is_binary(url) do
    case Req.post(url, json: %{content: message}) do
      {:ok, %Req.Response{status: status}} when status in 200..299 ->
        :ok

      {:ok, %Req.Response{status: status, body: body}} ->
        Logger.error("Discord delivery failed with status #{status}: #{inspect(body)}")
        {:error, :http_status}

      {:error, reason} ->
        Logger.error("Discord delivery failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def deliver(_message, _config) do
    {:error, :invalid_config}
  end
end
