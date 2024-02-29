defmodule Chatbot.Worker do
  use GenServer
  require Logger

  @moduledoc """
  Chatbot.Worker is responsible for interacting with the user,
  it should also manage the state of the conversation.

  Multiple Chatbot.Workers are initialized during the app execution, in fact, there should
  be as many Chatbot.Workers as Users using the app concurrently in a given moment.
  """

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

  def handle_cast(:answer, state) do
    Logger.info("Cast")
    state = %{user: state.user, status: nil}
    {:noreply, state}
  end
end
