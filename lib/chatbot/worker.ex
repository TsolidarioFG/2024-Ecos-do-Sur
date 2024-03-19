defmodule Chatbot.Worker do
  use GenServer
  require Logger
  import ChatBot.Gettext
  alias Chatbot.Cache, as: Cache
  alias Chatbot.TelegramWrapper, as: TelegramWrapper

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
    state = %{leader: nil, key: nil, user: nil, lang: nil, resolved: false, timer_ref: nil}
    {:ok, state}
  end

  # When the Worker does not reveive any messages from the user for a given time it will die.
  @impl GenServer
  def handle_info(:timeout, state) do
    {:stop, :timeout,  state}
  end

  # The worker is called by the leader cause a new message was received
  @impl GenServer
  def handle_call({:answer, key, user}, {leader_pid, _}, _) do
    find_conversation_and_start(user,
      fn -> do_ask_for_language_preferences(leader_pid, key, user, gettext("En qué idioma quieres que te responda?")) end,
      fn value ->
        new_state = reset_timer(do_ask_for_permission_late(value))
        {:reply, user, new_state}
      end
    )
  end

  # The worker is called by the leader cause a new query was received
  @impl GenServer
  def handle_call({:answer, key, user, query}, {leader_pid, _}, _) do
    Logger.info("Call")
    TelegramWrapper.answer_callback_query(key, query["id"])
    find_conversation_and_start(user,
      fn ->
        do_ask_for_language_preferences(leader_pid, key, user, gettext("La conversación anterior ya ha sido borrada"))
      end,
      fn value ->
        case query["data"] do
          "yes" ->
            TelegramWrapper.send_message(key, user, gettext("Describe what happened"))
            {:reply, user, value}
          "no" ->
            TelegramWrapper.send_message(
                    key,
                    user,
                    gettext("thank you"))
            GenServer.cast(:Cache, {:delete, user})
            {:stop, :normal, :worker_dead, value}
        end
      end
    )
  end

  @impl GenServer
  def handle_cast({:answer, update}, state) do
    Logger.info("Cast")
    do_handle_update(update, reset_timer(state))
  end

  # Terminates the process when an error occured
  @impl GenServer
  def terminate(:shutdown, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("error_message")})
  end

  # Terminates the process when no error occured
  @impl GenServer
  def terminate(:normal, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("Bye")})
  end

  @impl GenServer
  def terminate(:timeout, %{leader: leader, user: user} = state) do
    stop_timeout_timer(state)
    case Cache.get(user) do
      :not_found ->
        GenServer.cast(leader, {:worker_dead, self(), user, gettext("Due to inactivity the conversation will be ended")})
      _ ->   GenServer.cast(leader, {:worker_dead, self(), user, nil})
    end
  end

  # Handles an update when it has a callback query
  defp do_handle_update(%{"callback_query" => query, "update_id" => _}, state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    if state.resolved do # If the conversation was already resolved
      case query["data"] do
        "yes" ->
          TelegramWrapper.send_message(state.key, state.user, gettext("Describe what happened"))
          GenServer.cast(:Cache, {:delete, state.user})
          {:stop, :normal, state}
        "no" ->
          TelegramWrapper.send_message(
                  state.key,
                  state.user,
                  gettext("thank you"))
          GenServer.cast(:Cache, {:delete, state.user})
          {:stop, :normal, state}
        _ -> {:noreply, state}
      end
    else # If the conversation is still being solved
      if state.lang == nil do
        Gettext.put_locale(query["data"])
        TelegramWrapper.send_message(state.key, state.user, gettext("Language has been set."))
        final_state = do_ask_for_permission(%{state | lang: query["data"]})
        GenServer.cast(:Cache, {:update, {state.user,  final_state}})
        {:noreply,  final_state}
      else
        {:noreply, state}
      end
    end
  end

  # Handles an update when it does just contain a message
  # For now, it raises an error killing the process
  defp do_handle_update(%{"message" => msg, "update_id" => _}, state) do
    {:noreply, state}
  end


  defp do_ask_for_language_preferences(leader_pid, key, user, message) do
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
    state =reset_timer(%{leader: leader_pid, key: key, user: user, lang: nil, resolved: false, timer_ref: nil})
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
    new_state =%{state | resolved: true}
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
    %{state | resolved: true}
  end

  # Decides which function to run from the result of Cache.get
  defp find_conversation_and_start(user, not_found_function, found_function) do
    case Cache.get(user) do
      :not_found -> not_found_function.()
      value -> found_function.(value)
    end
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

  defp cancel_existing_timer(ref) do
    case ref do
      nil -> :ok
      ref -> :timer.cancel(ref)
    end
  end

end
