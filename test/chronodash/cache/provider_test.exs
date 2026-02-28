defmodule Chronodash.Cache.ProviderTest do
  use ExUnit.Case, async: true

  alias Chronodash.Cache.Provider.Cachex, as: CachexProvider

  setup do
    Code.ensure_loaded!(CachexProvider)
    :ok
  end

  describe "behaviour callbacks" do
    test "defines get/1 callback" do
      assert function_exported?(CachexProvider, :get, 1)
    end

    test "defines put/3 callback" do
      assert function_exported?(CachexProvider, :put, 3)
    end

    test "defines delete/1 callback" do
      assert function_exported?(CachexProvider, :delete, 1)
    end

    test "defines clear/0 callback" do
      assert function_exported?(CachexProvider, :clear, 0)
    end

    test "defines child_spec/1 callback" do
      assert function_exported?(CachexProvider, :child_spec, 1)
    end
  end

  describe "implementation compliance" do
    test "Cachex provider implements all required functions" do
      functions = [:get, :put, :delete, :clear, :child_spec]
      arities   = [1, 3, 1, 0, 1]

      for {fun, arity} <- Enum.zip(functions, arities) do
        assert function_exported?(CachexProvider, fun, arity),
               "CachexProvider does not implement #{fun}/#{arity}"
      end
    end
  end
end
