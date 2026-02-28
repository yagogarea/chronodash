defmodule Chronodash.Config do
  @moduledoc "Application configuration helpers."

  @spec cache_backend() :: module()
  def cache_backend do
    Application.get_env(:chronodash, :cache_backend, Chronodash.Cache.Provider.Cachex)
  end
end
