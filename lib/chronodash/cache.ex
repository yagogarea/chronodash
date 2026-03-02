defmodule Chronodash.Cache do
  @moduledoc """
  Public cache API.
  """

  @type key :: term()
  @type value :: term()
  @type ttl :: non_neg_integer() | :infinity
  @type opts :: Keyword.t()

  def get(key), do: provider().get(key)

  @doc "Stores a value in the cache with the given TTL in seconds, or ':infinity' for no expiration."
  def put(key, value, ttl), do: provider().put(key, value, ttl)
  @doc "Stores a value in the cache with no expiration."
  def put(key, value), do: put(key, value, :infinity)
  def delete(key), do: provider().delete(key)
  def clear, do: provider().clear()

  def child_spec(opts \\ []) do
    provider().child_spec(opts)
  end

  defp provider do
    Chronodash.Config.cache_backend()
  end
end
