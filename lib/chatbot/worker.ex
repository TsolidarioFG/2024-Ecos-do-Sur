defmodule Chatbot.Worker do
  use GenServer
  require Logger
  import ChatBot.Gettext
  alias Chatbot.Cache, as: Cache
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.Manager, as: Manager

  @moduledoc """
  Chatbot.Worker is responsible for interacting with the user,
  it should also manage the state of the conversation.

  Multiple Chatbot.Workers are initialized during the app execution, in fact, there should
  be as many Chatbot.Workers as Users using the app concurrently in a given moment.
  """

  # The process will be terminated after @timeout_interval milliseconds of inactivity.
  # TODO: Set a value for production
  @timeout_interval 30000 # 30 seconds in milliseconds

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Logger.info("Worker Initialized")
    state = %{leader: nil, key: nil, user: nil, lang: nil, timer_ref: nil, graph_state: {{:start, :initial}, [], nil}, stop_pause: false, last_message: nil}
    {:ok, state}
  end

  # When the Worker does not reveive any messages from the user for a given time it will die.
  @impl GenServer
  def handle_info(:timeout, state) when state.graph_state != {:solved, nil, nil} do
    TelegramWrapper.delete_message(state.key, state.user, state.last_message)
    {:stop, :timeout,  state}
  end
  @impl GenServer
  def handle_info(:timeout, state), do: {:stop, :timeout,  state}


  # The worker is called by the leader cause a new message was received
  @impl GenServer
  def handle_call({:answer, key, user, lang}, {leader_pid, _}, state) do
    Gettext.put_locale(lang)
    find_conversation_and_start(user,
      fn -> do_ask_for_language_preferences(leader_pid, key, user, gettext("En qué idioma quieres que te responda?"), state) end,
      fn value ->
        new_state = reset_timer(do_ask_for_permission_late(value))
        {:reply, user, new_state}
      end
    )
  end

  # The worker is called by the leader cause a new query was received
  @impl GenServer
  def handle_call({:answer, key, user, query, lang}, {leader_pid, _}, state) do
    Logger.info("Call")
    Gettext.put_locale(lang)
    TelegramWrapper.answer_callback_query(key, query["id"])
    find_conversation_and_start(user,
      fn ->
        do_ask_for_language_preferences(leader_pid, key, user, gettext("La conversación anterior ya ha sido borrada"), state)
      end,
      fn value ->
        case query["data"] do
          "yes" ->
            TelegramWrapper.delete_message(key, user, query["message"]["message_id"])
            do_delegate(value, :with_information)
            {:stop, :silence, :worker_dead, value}
          "no" ->
            TelegramWrapper.delete_message(key, user, query["message"]["message_id"])
            do_delegate(value, :without_information)
            {:stop, :silence, :worker_dead, value}
        end
      end
    )
  end

  @impl GenServer
  def handle_cast({:answer, update}, state) do
    Logger.info("Cast")
    do_handle_update(update, reset_timer(state))
  end


  @impl GenServer
  def handle_cast({:last_message, message_id}, state) do
    {:noreply, %{state | last_message: message_id}}
  end

  # Terminates the process when no error occured
  @impl GenServer
  def terminate(:normal, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("Bye")})
    :poolboy.checkin(:worker, self())
  end

  @impl GenServer
  def terminate(:timeout, %{leader: leader, user: user} = state) do
    stop_timeout_timer(state)
    case Cache.get(user) do
      :not_found ->
        GenServer.cast(leader, {:worker_dead, self(), user, gettext("Due to inactivity the conversation will be ended")})
      _ ->   GenServer.cast(leader, {:worker_dead, self(), user, nil})
    end
    :poolboy.checkin(:worker, self())
  end

  @impl GenServer
  def terminate(:silence, state) do
    stop_timeout_timer(state)
    :poolboy.checkin(:worker, self())
  end

  @impl GenServer
  def terminate(_, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("error_message")})
    :poolboy.checkin(:worker, self())
  end

  # Handles an update when it has a callback query, the conversation was not resolved and also the language was not set.
  defp do_handle_update(%{"callback_query" => query, "update_id" => _}, %{lang: nil} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    Gettext.put_locale(query["data"])
    new_graph_state = Manager.resolve(state.graph_state, state.user, state.key, nil, query["message"]["message_id"])
    {:noreply,  %{state | graph_state: new_graph_state, lang: query["data"]}}
  end

  # Called when the conversation is paused and a callback query is received
  defp do_handle_update(%{"callback_query" => query, "update_id" => _}, %{stop_pause: true} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    case query["data"] do
      "YES" ->
        new_graph_state = Manager.resolve({{:start, :initial}, [], nil}, state.user, state.key, query["data"], query["message"]["message_id"])
        {:noreply, %{state | graph_state: new_graph_state, stop_pause: false}}
      "NO" ->
        new_state = Manager.resolve(state.graph_state, state.user, state.key, "CONTINUE", query["message"]["message_id"])
        {:noreply, %{state | graph_state: new_state, stop_pause: false}}
      "EXIT" ->
        TelegramWrapper.delete_message(state.key, state.user, query["message"]["message_id"])
        {:stop, :normal, %{state | graph_state: {:solved, nil, nil}}}
      _ -> {:noreply, state}
    end
  end

  # Handles an update when it has a callback query and the conversation is solved already
  defp do_handle_update(%{"callback_query" => query, "update_id" => _}, %{graph_state: {:solved, _, _}} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    case query["data"] do
      "yes" ->
        TelegramWrapper.delete_message(state.key, state.user, query["message"]["message_id"])
        do_delegate(state, :with_information)
        {:stop, :silence, state}
      "no" ->
        TelegramWrapper.delete_message(state.key, state.user, query["message"]["message_id"])
        do_delegate(state, :without_information)
        {:stop, :silence, state}
      _ -> {:noreply, state}
    end
  end

  # Handles an update when it has a callback query. Resolves the graph state.
  defp do_handle_update(%{"callback_query" => query, "update_id" => _}, state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    new_graph_state = Manager.resolve(state.graph_state, state.user, state.key, query["data"],query["message"]["message_id"] )
    {st, _, _} = new_graph_state
    if st == :solved do
      do_ask_for_permission(state)
    end
    {:noreply,  %{state | graph_state: new_graph_state}}
  end

  # The bot receives a text message so it asks whether to restart or continue the conversation
  defp do_handle_update(%{"message" => _, "update_id" => _}, %{graph_state: {status, _, _}} = state) when status != :solved and state.lang != nil do
    TelegramWrapper.delete_message(state.key, state.user, state.last_message)
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}], [%{text: gettext("EXIT"), callback_data: "EXIT"}]]
        TelegramWrapper.send_menu(
          keyboard,
          gettext("RESTART"),
          state.user,
          state.key
        )
    {:noreply, %{state | stop_pause: true}}
  end

  # Ignore any unexpected messages that are not part of the conversation.
  defp do_handle_update(%{"message" => _, "update_id" => _}, state), do: {:noreply, state}

  defp do_ask_for_language_preferences(leader_pid, key, user, message, state) do
    keyboard = [
      [%{text: "🇪🇸", callback_data: "es"}, %{text: "🇬🇧", callback_data: "en"}],
      [%{text: "🇫🇷", callback_data: "fr"}]
    ]
    TelegramWrapper.send_menu(
      keyboard,
      message,
      user,
      key
    )
    state =reset_timer(%{state | leader: leader_pid, key: key, user: user})
    {:reply, user, state}
  end

  # Asks the user if he/she wants to add more data to be stored in our servers
  defp do_ask_for_permission(state) do
    keyboard = [
      [%{text: gettext("YES"), callback_data: "yes"}, %{text: gettext("NO"), callback_data: "no"}]
    ]
    TelegramWrapper.send_menu(
      keyboard,
      gettext("Are we allowed to save this conversation?"),
      state.user,
      state.key
    )
    new_state =%{state | graph_state: {:solved, nil, nil}}
    GenServer.cast(:Cache, {:put_new, {state.user, new_state}})
    new_state
  end

  # Asks the user if he/she wants to add more data to be stored in our servers
  defp do_ask_for_permission_late(state) do
    keyboard = [
      [%{text: gettext("YES"), callback_data: "yes"}, %{text: gettext("NO"), callback_data: "no"}]
    ]
    TelegramWrapper.send_menu(
      keyboard,
      gettext("We have a conversation not closed yet. Do you want to add more information about it?"),
      state.user,
      state.key
    )
    %{state | graph_state: {:solved, nil, nil}}
  end

  # Decides which function to run from the result of Cache.get
  defp find_conversation_and_start(user, not_found_function, found_function) do
    case Cache.get(user) do
      :not_found -> not_found_function.()
      value -> found_function.(value)
    end
  end

  defp do_delegate(state, :with_information) do
    information_collector_pid = :poolboy.checkout(:collector)
    GenServer.call(information_collector_pid, {:initialize, state})
    GenServer.cast(state.leader, {:worker_substitute, self(), information_collector_pid, state.user})
    GenServer.cast(:Cache, {:delete, state.user})
  end

  defp do_delegate(state, :without_information) do
    information_collector_pid = :poolboy.checkout(:collector)
    GenServer.call(information_collector_pid, {:initialize, state})
    GenServer.cast(state.leader, {:worker_substitute_skip, self(), information_collector_pid, state.user})
    GenServer.cast(:Cache, {:delete, state.user})
  end

  # A new timer is created, cancelling the previous one, if it exists.
  # This function is involved in the user inactivity use case.
  defp reset_timer(%{timer_ref: timer_ref} = state) do
    cancel_existing_timer(timer_ref)
    {_,timer_ref} = :timer.send_interval(@timeout_interval, self(), :timeout)
    %{state | timer_ref: timer_ref}
  end

  # If there exists a scheduled timer, this function will cancel it.
  defp stop_timeout_timer(%{timer_ref: timer_ref} = state) do
    cancel_existing_timer(timer_ref)
    %{state | timer_ref: nil}
  end

  defp cancel_existing_timer(nil), do: :ok
  defp cancel_existing_timer(ref), do: :timer.cancel(ref)

end
