defmodule Chatbot.Worker do
  use GenServer
  require Logger
  import ChatBot.Gettext
  alias Chatbot.TelegramWrapper, as: TelegramWrapper

  @moduledoc """
  Chatbot.Worker is responsible for interacting with the user,
  it should also manage the state of the conversation.

  Multiple Chatbot.Workers are initialized during the app execution, in fact, there should
  be as many Chatbot.Workers as Users using the app concurrently in a given moment.
  alias Chatbot.TelegramWrapper
  """


  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Logger.info("Worker Initialized")
    state = %{leader: nil, key: nil, user: nil, lang: nil, status: nil}
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:answer, key, user}, {leader_pid, _}, _) do
    Logger.info("Call")
    keyboard = [
      [%{text: "🇪🇸", callback_data: "es"}, %{text: "🇬🇧", callback_data: "en"}],
      [%{text: "🇫🇷", callback_data: "fr"}]
    ]
    TelegramWrapper.send_menu(
      keyboard,
      "En qué idioma quieres que te responda?",
      user,
      key
    )
    state = %{leader: leader_pid, key: key, user: user, lang: nil, status: nil}
    {:reply, user, state}
  end


  @impl GenServer
  def handle_cast({:answer, update}, state) do
    Logger.info("Cast")
    finalState = do_handle_update(update, state)
    {:noreply, finalState}
  end

  @impl GenServer
  def terminate(_, state) do
    GenServer.cast(state.leader, {:worker_dead, self(), gettext("error_message")})
  end

  # Handles an update when it has a callback query
  defp do_handle_update(%{"callback_query" => query, "update_id" => _}, state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    if state.lang == nil do
      Gettext.put_locale(query["data"])
      TelegramWrapper.send_message(state.key, query["from"]["id"], gettext("Language has been set."))
      %{state | lang: query["data"]}
    else
      state
    end
  end

  # Handles an update when it does just contain a message
  # For now, it raises an error killing the process
  defp do_handle_update(%{"message" => msg, "update_id" => _}, state) do
    raise "Simulated failure: Something went wrong in do_handle_update!"
  end
end
