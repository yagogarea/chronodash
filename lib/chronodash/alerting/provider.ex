defmodule Chronodash.Alerting.Provider do
  @moduledoc """
  Behaviour for alert delivery channels (Discord, Telegram, etc).
  """

  @callback deliver(message :: String.t(), config :: map()) :: :ok | {:error, any()}
end
