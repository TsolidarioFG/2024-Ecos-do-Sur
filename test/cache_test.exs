defmodule CacheTest do
  use ExUnit.Case
  doctest Chatbot.Cache

  test "get" do
    GenServer.cast(:Cache, {:put_new, {:testing_key_get, %{saved: true}}})
    Process.sleep(20)
    res = Chatbot.Cache.get(:testing_key_get)
    assert res != :not_found
    GenServer.cast(:Cache, {:delete, :testing_key_get})
  end

  test "update" do
    GenServer.cast(:Cache, {:put_new, {:testing_key_update, %{saved: true}}})
    Process.sleep(20)
    GenServer.cast(:Cache, {:update, {:testing_key_update, %{saved: false}}})
    Process.sleep(20)
    res = Chatbot.Cache.get(:testing_key_update)
    assert res == %{saved: false}
    GenServer.cast(:Cache, {:delete, :testing_key_update})
  end

  test "delete" do
    GenServer.cast(:Cache, {:put_new, {:testing_key_delete, %{saved: true}}})
    Process.sleep(20)
    GenServer.cast(:Cache, {:delete, :testing_key_delete})
    Process.sleep(20)
    res = Chatbot.Cache.get(:testing_key_delete)
    assert res == :not_found
  end
end
