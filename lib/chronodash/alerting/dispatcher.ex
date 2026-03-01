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

defmodule Chronodash.Alerting.Dispatcher do
  @moduledoc """
  Dispatches alert messages to configured channel providers.
  """
  require Logger

  alias Chronodash.Alerting.Providers

  @providers %{
    discord: Providers.Discord
  }

  # ============================================================================
  # Public API
  # ============================================================================

  @doc """
  Sends a message to a list of channels.
  """
  def dispatch(message, channel_keys) when is_list(channel_keys) do
    config = Application.get_env(:chronodash, :alerts, [])
    channel_configs = Keyword.get(config, :channels, %{})

    Enum.each(channel_keys, fn key ->
      case Map.get(channel_configs, key) do
        nil ->
          Logger.warning("Attempted to dispatch to unknown channel: #{key}")

        chan_config ->
          do_dispatch(message, key, chan_config)
      end
    end)
  end

  defp do_dispatch(message, key, config) do
    case Map.get(@providers, key) do
      nil ->
        Logger.error("No provider implementation for channel type: #{key}")

      provider ->
        # We wrap in Task.start to ensure alerting doesn't block the caller
        Task.start(fn ->
          provider.deliver(message, config)
        end)
    end
  end
end
