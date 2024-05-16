defmodule CacheTest do
  use ExUnit.Case
  doctest Chatbot.Cache

  setup_all do
    GenServer.cast(:Cache, {:put_new, {:testing_key, %{saved: true}}})
    # Delay to ensure that the previous cast was completed.
    Process.sleep(20)
    on_exit(fn ->
      GenServer.cast(:Cache, {:delete, :testing_key})
      Process.sleep(20)
    end)
  end

  test "get" do
    res = Chatbot.Cache.get(:testing_key)
    assert res != :not_found
  end

  test "update" do
    GenServer.cast(:Cache, {:update, {:testing_key, %{saved: false}}})
    Process.sleep(20)
    res = Chatbot.Cache.get(:testing_key)
    assert res == %{saved: false}
  end

  test "delete" do
    GenServer.cast(:Cache, {:delete, :testing_key})
    Process.sleep(20)
    res = Chatbot.Cache.get(:testing_key)
    assert res == :not_found
  end
end
