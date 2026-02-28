defmodule Chronodash.Cache.Provider.Cachex do
  @moduledoc """
  Cache provider backed by Cachex.

  TTL values received are in seconds and converted to milliseconds
  as required by the Cachex API.
  """

  @behaviour Chronodash.Cache.Provider

  require Logger

  @cache_name :chronodash_cache

  @impl true
  @spec child_spec(Chronodash.Cache.opts()) :: Supervisor.child_spec()
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {Cachex, :start_link, [@cache_name, []]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @impl true
  @spec get(Chronodash.Cache.key()) :: {:ok, Chronodash.Cache.value()} | :miss
  def get(key) do
    case Cachex.get(@cache_name, key) do
      {:ok, nil} -> :miss
      {:ok, value} -> {:ok, value}
      {:error, reason} ->
        Logger.warning("Cache get failed for key #{inspect(key)}: #{inspect(reason)}")
        :miss
    end
  end

  @impl true
  @spec put(Chronodash.Cache.key(), Chronodash.Cache.value(), Chronodash.Cache.ttl()) :: :ok
  def put(key, value, ttl) do
    opts = ttl_opts(ttl)

    case Cachex.put(@cache_name, key, value, opts) do
      {:ok, true} -> :ok
      {:error, reason} ->
        Logger.warning("Cache put failed for key #{inspect(key)}: #{inspect(reason)}")
        :ok
    end
  end

  @impl true
  @spec delete(Chronodash.Cache.key()) :: :ok
  def delete(key) do
    case Cachex.del(@cache_name, key) do
      {:ok, _} -> :ok
      {:error, reason} ->
        Logger.warning("Cache delete failed for key #{inspect(key)}: #{inspect(reason)}")
        :ok
    end
  end

  @impl true
  @spec clear() :: :ok
  def clear do
    case Cachex.clear(@cache_name) do
      {:ok, _} -> :ok
      {:error, reason} ->
        Logger.warning("Cache clear failed: #{inspect(reason)}")
        :ok
    end
  end

  @spec ttl_opts(Chronodash.Cache.ttl()) :: Keyword.t()
  defp ttl_opts(:infinity), do: []
  defp ttl_opts(ttl) when is_integer(ttl) and ttl > 0, do: [ttl: :timer.seconds(ttl)]
end
