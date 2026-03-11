defmodule Chronodash.CacheTest do
  use ExUnit.Case, async: true

  alias Chronodash.Cache

  setup do
    # Kill any existing cache process to ensure a clean slate for each test
    if Process.whereis(Cache) do
      GenServer.stop(Cache)
    end

    start_supervised!({Cachex, :chronodash_cache})
    :ok
  end

  describe "get/1" do
    test "returns :miss for a key that does not exist" do
      assert :miss = Cache.get("nonexistent")
    end

    test "returns {:ok, value} for an existing key" do
      Cache.put("key", "value", :infinity)
      assert {:ok, "value"} = Cache.get("key")
    end
  end

  describe "put/3" do
    test "stores and retrieves a value" do
      assert :ok = Cache.put("key", "value", :infinity)
      assert {:ok, "value"} = Cache.get("key")
    end

    test "overwrites an existing value" do
      Cache.put("key", "original", :infinity)
      Cache.put("key", "updated", :infinity)
      assert {:ok, "updated"} = Cache.get("key")
    end

    test "stores different value types" do
      Cache.put("integer", 42, :infinity)
      Cache.put("map", %{a: 1}, :infinity)
      Cache.put("list", [1, 2, 3], :infinity)
      Cache.put("atom", :my_atom, :infinity)

      assert {:ok, 42} = Cache.get("integer")
      assert {:ok, %{a: 1}} = Cache.get("map")
      assert {:ok, [1, 2, 3]} = Cache.get("list")
      assert {:ok, :my_atom} = Cache.get("atom")
    end

    test "value expires after TTL" do
      Cache.put("key", "value", 1)
      assert {:ok, "value"} = Cache.get("key")
      :timer.sleep(1_100)
      assert :miss = Cache.get("key")
    end

    test "value does not expire when TTL is :infinity" do
      Cache.put("key", "value", :infinity)
      :timer.sleep(100)
      assert {:ok, "value"} = Cache.get("key")
    end
  end

  describe "put/2" do
    test "stores a value with no expiration" do
      assert :ok = Cache.put("key", "value")
      assert {:ok, "value"} = Cache.get("key")
    end
  end

  describe "delete/1" do
    test "removes an existing key" do
      Cache.put("key", "value", :infinity)
      assert :ok = Cache.delete("key")
      assert :miss = Cache.get("key")
    end

    test "returns :ok when deleting a nonexistent key" do
      assert :ok = Cache.delete("nonexistent")
    end
  end

  describe "clear/0" do
    test "removes all entries" do
      Cache.put("key1", "value1", :infinity)
      Cache.put("key2", "value2", :infinity)
      Cache.put("key3", "value3", :infinity)

      assert :ok = Cache.clear()

      assert :miss = Cache.get("key1")
      assert :miss = Cache.get("key2")
      assert :miss = Cache.get("key3")
    end

    test "returns :ok when cache is already empty" do
      assert :ok = Cache.clear()
    end
  end
end
