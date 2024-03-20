defmodule Chatbot.InformationCollector do
  use GenServer
  require Logger
  import ChatBot.Gettext
  alias Chatbot.TelegramWrapper, as: TelegramWrapper

  @moduledoc """
  InformationCollector is the one in charge of asking the user information to be stored in our
  servers. It's invoked when a user agrees to add more information and allow us to save it.

  If the user enters and state of inactivity, the already filled information is missed.
  """

  @timeout_interval 30000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    Logger.info("An InformationCollector was initialized")
    {:ok, %{leader: nil, key: nil, user: nil, lang: nil, timer_ref: nil, data: %{description: nil, location: nil, gender: nil}}}
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    {:stop, :timeout,  state}
  end

  @impl GenServer
  def terminate(:normal, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("Bye")})
  end

  @impl GenServer
  def terminate(:timeout, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("Due to inactivity the conversation will be ended")})
  end

  @impl true
  def handle_call({:initialize, ws}, _from, state) do
    Gettext.put_locale(ws.lang)
    {:reply, :ok, %{state | leader: ws.leader, key: ws.key, user: ws.user, lang: ws.lang}}
  end

  @impl true
  def handle_cast(:stablished, state) do
    TelegramWrapper.send_message(state.key, state.user, gettext("Describe what happened"))
    {:noreply, reset_timer(state)}
  end

  @impl true
  def handle_cast({:answer, %{"message" => msg, "update_id" => _}}, %{data: %{description: nil}} = state) do
    TelegramWrapper.send_message(state.key, state.user, gettext("Where did it happen?"))
    {:noreply, %{state | data: %{description: msg["text"], location: nil, gender: nil}}}
  end

  @impl true
  def handle_cast({:answer, %{"message" => msg, "update_id" => _}}, %{data: %{location: nil}} = state) do
    keyboard = [
      [%{text: "♂️", callback_data: "male"}, %{text: "♀️", callback_data: "female"}],
      [%{text: "⚧️", callback_data: "other"}]
    ]
    TelegramWrapper.send_menu(
      keyboard,
      "Select your gender",
      state.user,
      state.key
    )
    {:noreply, %{state | data: %{description: state.data.description, location: msg["text"], gender: nil}}}
  end

  @impl true
  def handle_cast({:answer, %{"callback_query" => query, "update_id" => _}}, %{data: %{gender: nil}} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    if query["data"] in ["male", "female", "other"] do
      new_state =  %{state | data: %{description: state.data.description, location: state.data.location, gender: query["data"]}}
      save_data(new_state)
      {:stop, :normal, new_state}
    else
      {:noreply, state}
    end
  end

  defp save_data(state) do
    case GenServer.call(:Persistence, {:store, Chatbot.DbDataScheme.new(state.data.location, state.data.description, state.data.gender)}) do
      :not_created -> TelegramWrapper.send_message(state.key, state.user, "Due to a server problem this information couln't be saved.")
      _ -> TelegramWrapper.send_message(state.key, state.user, "This information has been saved successfully")
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

  defp cancel_existing_timer(nil), do: :ok
  defp cancel_existing_timer(ref), do: :timer.cancel(ref)

end
