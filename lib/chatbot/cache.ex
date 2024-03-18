defmodule Chatbot.Cache do
  use GenServer
  require Logger

  @moduledoc """
  This module represents a Cache. It uses ETS to store data while the process is running.
  When a user's conversation reaches the end, it's state will be stored in the Cache.

  The read_concurrency option of ETS is set to TRUE so that Workes can handle their reading
  necessities by themselves.
  """

  # Time in milliseconds by which the Cache must do a clean up of items that are passed the ttl
  @ttl 120000 # 2 minutes in milliseconds

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :Cache)
  end

  @impl true
  def init(_) do
      Logger.info("Cache Initialized")
      table = :ets.new(:conversation_cache, [:named_table, read_concurrency: true])
      schedule_ttl_cleanup()
      {:ok, table}
  end

  # Inserts an item in the cache. The key must not be already contained in the cache.
  @impl true
  def handle_cast({:put_new, {key, value}}, table) do
    :ets.insert_new(table, {key, {value, System.system_time(:millisecond)}})
    {:noreply, table}
  end

  # Updates an already existing key with a new value.
  @impl true
  def handle_cast({:update, {key, value}}, table) do
    :ets.insert(table, {key, {value, System.system_time(:millisecond)}})
    {:noreply, table}
  end

  # Removes a key's entry from the cache
  @impl true
  def handle_cast({:delete, key}, table) do
    :ets.delete(table, key)
    {:noreply, table}
  end

  # Retrieves the value associated with a key. If the key didn't exist or the entry is passed
  # the ttl :not_found would be returned.
  def get(key) do
    case :ets.lookup(:conversation_cache, key) do
      [{_, {value, date}}] -> if date < @ttl + System.system_time(:millisecond) do value else :not_found end
      [] -> :not_found
    end
  end

  # Handles a :cleanup message eliminating items that are passed the ttl from the table
  @impl true
  def handle_info(:cleanup, table) do
    current_time = System.system_time(:millisecond)
    :ets.select_delete(table, [{{:"$1", {:"$2", :"$3"}}, [{:<, :"$3", @ttl + current_time}], [true]}])
    schedule_ttl_cleanup()
    {:noreply, table}
  end

  # Schedules a clean up
  defp schedule_ttl_cleanup do
    Process.send_after(self(), :cleanup, @ttl)
  end
end
