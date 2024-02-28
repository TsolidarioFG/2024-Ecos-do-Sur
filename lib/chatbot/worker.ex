defmodule Chatbot.Worker do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    Logger.info("Worker Initialized")
    state = %{user: nil, status: nil}
    {:ok, state}
  end

  def handle_call({:answer, user}, _from, _) do
    Logger.info("Call")
    state = %{user: user, status: nil}
    {:reply, user, state}
  end

  def handle_cast({:answer, user}, _) do
    Logger.info("Cast")
    state = %{user: user, status: nil}
    {:noreply, state}
  end
end
