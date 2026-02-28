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
