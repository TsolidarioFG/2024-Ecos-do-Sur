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
    {:ok, %{leader: nil, key: nil, user: nil, lang: nil, timer_ref: nil, data: %{birth_location: nil, age: nil, gender: nil, ca: nil, description: nil, review: nil}}}
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    {:stop, :timeout,  state}
  end

  @impl GenServer
  def terminate(:normal, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("Bye")})
    :poolboy.checkin(:collector, self())
  end

  @impl GenServer
  def terminate(:timeout, state) do
    stop_timeout_timer(state)
    GenServer.cast(state.leader, {:worker_dead, self(), state.user, gettext("Due to inactivity the conversation will be ended. It wont be saved.")})
    :poolboy.checkin(:collector, self())
  end

  @impl true
  def handle_call({:initialize, ws}, _from, state) do
    Gettext.put_locale(ws.lang)
    {:reply, :ok, %{state | leader: ws.leader, key: ws.key, user: ws.user, lang: ws.lang}}
  end

  # Iniciate conversation, ask for birth place:
  @impl true
  def handle_cast(:stablished, state) do
    TelegramWrapper.send_message(state.key, state.user, gettext("Birth Location? (COUNTRY)"))
    {:noreply, reset_timer(state)}
  end

  # Receive birth place answer and ask for age:
  @impl true
  def handle_cast({:answer, %{"message" => msg, "update_id" => _}}, %{data: %{birth_location: nil} = data} = state) do
    TelegramWrapper.send_message(state.key, state.user, gettext("How old are you?"))
    {:noreply, reset_timer(%{state | data: %{data | birth_location: msg["text"]}})}
  end

  # Receive age answer and ask for gender:
  @impl true
  def handle_cast({:answer, %{"message" => msg, "update_id" => _}}, %{data: %{age: nil} = data} = state) do
    keyboard = [
      [%{text: "♂️", callback_data: "male"}, %{text: "♀️", callback_data: "female"}],
      [%{text: "⚧️", callback_data: "other"}]
    ]
    TelegramWrapper.send_menu(keyboard, gettext("Please, select your gender:"), state.user, state.key)
    {:noreply, reset_timer(%{state | data: %{data | age: msg["text"]}})}
  end

  # Receive gender answer and ask for CA:
  @impl true
  def handle_cast({:answer, %{"callback_query" => query, "update_id" => _}}, %{data: %{gender: nil} = data} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    if query["data"] in ["male", "female", "other"] do
      do_ask_ccaa(state, query["message"]["message_id"])
      {:noreply, reset_timer(%{state | data: %{data | gender: query["data"]}})}
    else
      {:noreply, reset_timer(state)}
    end
  end

  # Receive CA answer and ask for description:
  @impl true
  def handle_cast({:answer, %{"callback_query" => query, "update_id" => _}}, %{data: %{ca: nil} = data} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    TelegramWrapper.update_menu(gettext("Describe what happened in detail."), state.user,query["message"]["message_id"], state.key)
    {:noreply, reset_timer(%{state | data: %{data | ca: query["data"]}})}
  end

  # Receive description and ask if the user is willing to add a review:
  @impl true
  def handle_cast({:answer, %{"message" => msg, "update_id" => _}}, %{data: %{description: nil} = data} = state) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}]]
    TelegramWrapper.send_menu(keyboard, gettext("Do you want to add a review?"), state.user, state.key)
    {:noreply, reset_timer(%{state | data: %{data | description: msg["text"]}})}
  end

  # The user does not want to leave a review:
  @impl true
  def handle_cast({:answer, %{"callback_query" => %{"data" => "NO"} = query, "update_id" => _}}, %{data: %{review: nil}} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    save_data(state)
    {:stop, :normal, reset_timer(state)}
  end

  # The user wants to leave a review. Ask for a star-based puntuation:
  @impl true
  def handle_cast({:answer, %{"callback_query" => %{"data" => "YES"} = query, "update_id" => _}}, %{data: %{review: nil}} = state) do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    keyboard = [[%{text: "⭐", callback_data: "1"}, %{text: "⭐", callback_data: "2"}, %{text: "⭐", callback_data: "3"}, %{text: "⭐", callback_data: "4"}, %{text: "⭐", callback_data: "5"}]]
        TelegramWrapper.update_menu(keyboard, gettext("Value the bot with the following stars:"), state.user, query["message"]["message_id"], state.key)
        {:noreply, reset_timer(state)}

  end

  # Receive star-based puntiation and ask if the user wants to leave a comment / suggestion:
  @impl true
  def handle_cast({:answer, %{"callback_query" => %{"data" => stars} = query, "update_id" => _}}, %{data: %{review: nil} = data} = state) when stars in ["1","2","3","4","5"]  do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    TelegramWrapper.update_menu([[%{text: "NO", callback_data: "NO"}]], gettext("Any suggestions or comments that you would like to write?"), state.user, query["message"]["message_id"], state.key)
    {:noreply, reset_timer(%{state | data: %{data | review: %{stars: stars, comment: nil}}})}
  end

  # The user does not want to leave a comment / suggestion:
  @impl true
  def handle_cast({:answer, %{"callback_query" => %{"data" => "NO"} = query, "update_id" => _}}, %{data: %{review: rev}} = state) when rev != nil do
    TelegramWrapper.answer_callback_query(state.key, query["id"])
    save_data(state)
    {:stop, :normal, reset_timer(state)}

  end

  # Receive user's comment / suggestion:
  @impl true
  def handle_cast({:answer, %{"message" => msg, "update_id" => _}}, %{data: %{review: rev} = data} = state) when rev != nil do
    new_state = %{state | data: %{data | review: %{stars: rev.stars, comment: msg["text"]}}}
    save_data(new_state)
    {:stop, :normal, reset_timer(new_state)}
  end

  ####################################################################
  ####################### PRIVATE FUNCTIONS ##########################
  ####################################################################

  # Asks the Spanish CA of the user:
  defp do_ask_ccaa(state, message_id) do
    keyboard = [
      [%{text: "GALICIA", callback_data: "GALIZA"}, %{text: "CATALUÑA", callback_data: "CATALUNYA"}],
      [%{text: "PAÍS VASCO", callback_data: "EUSKADI"}, %{text: "MADRID", callback_data: "MADRID"}],
      [%{text: "ANDALUCÍA", callback_data: "ANDALUCIA"}, %{text: "ARAGON", callback_data: "ARAGON"}],
      [%{text: "ASTURIAS", callback_data: "ASTURIAS"}, %{text: "BALEARES", callback_data: "BALEARES"}],
      [%{text: "CANARIAS", callback_data: "CANARIAS"}, %{text: "CANTABRIA", callback_data: "CANTABRIA"}],
      [%{text: "C. LA MANCHA", callback_data: "C. LA MANCHA"}, %{text: "C. LEÓN", callback_data: "C. LEÓN"}],
      [%{text: "COM. VALENCIANA", callback_data: "VALENCIA"}, %{text: "EXTREMADURA", callback_data: "EXTREMADURA"}],
      [%{text: "LA RIOJA", callback_data: "RIOJA"}, %{text: "MURCIA", callback_data: "MURCIA"}],
      [%{text: "NAVARRA", callback_data: "NAVARRA"}, %{text: "CEUTA", callback_data: "CEUTA"}],
      [%{text: "MELILLA", callback_data: "MELILLA"}]
    ]
    TelegramWrapper.update_menu(keyboard, gettext("In which CA did it happen?"), state.user, message_id, state.key)
  end


  # Saves the data contained in the state struct inside of the DB by calling the Persistence module:
  defp save_data(state) do
    case GenServer.call(:Persistence, {:store, Chatbot.DbDataScheme.new(state.data.birth_location, state.data.age, state.data.gender, state.data.ca, state.data.description, state.data.review)}) do
      :not_created -> TelegramWrapper.send_message(state.key, state.user, gettext("Due to a server problem this information couldn't be saved."))
      _ -> TelegramWrapper.send_message(state.key, state.user, gettext("This information has been saved successfully"))
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
