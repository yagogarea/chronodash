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
