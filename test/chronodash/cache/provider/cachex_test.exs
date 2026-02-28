defmodule Chronodash.Cache.Provider.CachexTest do
  use ExUnit.Case, async: true

  alias Chronodash.Cache.Provider.Cachex, as: CachexProvider

  setup do
    start_supervised!({Cachex, :chronodash_cache})
    :ok
  end

  describe "child_spec/1" do
    test "returns a valid supervisor child spec" do
      spec = CachexProvider.child_spec([])

      assert %{
               id: Chronodash.Cache.Provider.Cachex,
               start: {Cachex, :start_link, _},
               type: :worker,
               restart: :permanent,
               shutdown: 500
             } = spec
    end
  end

  describe "get/1" do
    test "returns :miss for a nonexistent key" do
      assert :miss = CachexProvider.get("nonexistent")
    end

    test "returns {:ok, value} for an existing key" do
      CachexProvider.put("key", "value", :infinity)
      assert {:ok, "value"} = CachexProvider.get("key")
    end
  end

  describe "put/3" do
    test "stores a value with :infinity TTL" do
      assert :ok = CachexProvider.put("key", "value", :infinity)
      assert {:ok, "value"} = CachexProvider.get("key")
    end

    test "stores a value with integer TTL in seconds" do
      assert :ok = CachexProvider.put("key", "value", 60)
      assert {:ok, "value"} = CachexProvider.get("key")
    end

    test "overwrites an existing value" do
      CachexProvider.put("key", "original", :infinity)
      CachexProvider.put("key", "updated", :infinity)
      assert {:ok, "updated"} = CachexProvider.get("key")
    end

    test "TTL is correctly converted from seconds to milliseconds" do
      CachexProvider.put("key", "value", 2)

      assert {:ok, "value"} = CachexProvider.get("key")

      # After 1.1s the value should still be present (TTL is 2s, not 2ms)
      :timer.sleep(1_100)
      assert {:ok, "value"} = CachexProvider.get("key")

      # After another 1.1s (2.2s total) the value should have expired
      :timer.sleep(1_100)
      assert :miss = CachexProvider.get("key")
    end

    test "value expires after TTL seconds" do
      CachexProvider.put("key", "value", 1)
      assert {:ok, "value"} = CachexProvider.get("key")
      :timer.sleep(1_100)
      assert :miss = CachexProvider.get("key")
    end

    test "value does not expire with :infinity TTL" do
      CachexProvider.put("key", "value", :infinity)
      :timer.sleep(100)
      assert {:ok, "value"} = CachexProvider.get("key")
    end
  end

  describe "delete/1" do
    test "removes an existing key" do
      CachexProvider.put("key", "value", :infinity)
      assert :ok = CachexProvider.delete("key")
      assert :miss = CachexProvider.get("key")
    end

    test "returns :ok for a nonexistent key" do
      assert :ok = CachexProvider.delete("nonexistent")
    end
  end

  describe "clear/0" do
    test "removes all entries" do
      CachexProvider.put("key1", "value1", :infinity)
      CachexProvider.put("key2", "value2", :infinity)

      assert :ok = CachexProvider.clear()

      assert :miss = CachexProvider.get("key1")
      assert :miss = CachexProvider.get("key2")
    end

    test "returns :ok when cache is already empty" do
      assert :ok = CachexProvider.clear()
    end
  end
end
