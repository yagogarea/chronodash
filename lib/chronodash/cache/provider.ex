defmodule Chronodash.Cache.Provider do
  @moduledoc """
  Behaviour for cache providers.
  """

  @callback child_spec(Cache.opts()) :: Supervisor.child_spec()
  @callback get(Cache.key()) :: {:ok, Cache.value()} | :miss
  @callback put(Cache.key(), Cache.value(), Cache.ttl()) :: :ok
  @callback delete(Cache.key()) :: :ok
  @callback clear() :: :ok
end
