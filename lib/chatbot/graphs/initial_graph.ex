defmodule Chatbot.InitialGraph do
  alias Chatbot.Manager
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  alias Manager
  require Logger
  import ChatBot.Gettext


  @doc """
  This module represents the Initial graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ####################################################################
  ############################# START ################################
  ####################################################################
  def resolve({:start, _, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("URGENT"), callback_data: "U1"}, %{text: gettext("INFORMATION"), callback_data: "I1"}]]
    history = [{:start, :initial}]
    TelegramWrapper.update_menu(
      keyboard,
      HistoryFormatting.buildMessage(gettext("INITIAL_Q1"), history),
      user,
      message_id,
      key
    )
    {{:start_final_resolve, :initial}, history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "U1", message_id), do: resolve({:U1, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "I1", message_id), do: resolve({:I1, history, nil}, user, key, nil, message_id)

  ####################################################################
  ############################ URGENT ################################
  ####################################################################

  ##################################
  # U1
  ##################################

  def resolve({:U1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("ME"), callback_data: "ME"}, %{text: gettext("OTHER"), callback_data: "OTHER"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U1, :initial} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("INITIAL_Q2"), new_history), user, message_id, key)
    {{:U1_resolve, :initial}, new_history, nil}
  end

  def resolve({:U1_resolve, history, _}, user, key, "ME", message_id), do: resolve({:U1_1, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, _}, user, key, "OTHER", message_id), do: resolve({:U1_2, history, nil}, user, key, nil, message_id)

  def resolve({:U1_1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "S1"}, %{text: gettext("NO"), callback_data: "U2"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U1_1, :initial} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("INITIAL_Q3"), new_history), user, message_id, key )
    {{:U1_final_resolve, :initial}, new_history, nil}
  end

  def resolve({:U1_2, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "S1"}, %{text: gettext("NO"), callback_data: "U3"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U1_2, :initial} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("INITIAL_Q4"), new_history), user, message_id, key)
    {{:U1_final_resolve, :initial}, new_history, nil}
  end

  def resolve({:U1_final_resolve, history, _}, user, key, "S1", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:U1_final_resolve, history, _}, user, key, "U2", message_id), do: resolve({:U2, history, nil}, user, key, nil, message_id)
  def resolve({:U1_final_resolve, history, _}, user, key, "U3", message_id), do: resolve({:U3, history, nil}, user, key, nil, message_id)

  ##################################
  # U2
  ##################################
  def resolve({:U2, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("LEISURE"), callback_data: "LEISURE"}, %{text: gettext("COMMERCE"), callback_data: "COMMERCE"}, %{text: gettext("WORK"), callback_data: "WORK"}, %{text: gettext("INSTITUTION"), callback_data: "GOVERN"}],
    [%{text: gettext("HOSPITAL"), callback_data: "HOSPITAL"}, %{text: gettext("TRANSPORT"), callback_data: "TRANSPORT"}, %{text: gettext("SCHOOL"), callback_data: "SCHOOL"}],
    [%{text: gettext("HOME"), callback_data: "HOME"}, %{text: gettext("STREET"), callback_data: "STREET"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U2, :initial} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("INITIAL_Q5"), new_history), user, message_id, key)
    {{:U2_resolve, :initial}, new_history, nil}
  end

  def resolve({:U2_resolve, history, _}, user, key, "HOME", message_id), do: resolve({:U2_4, history, "HOME"}, user, key, nil, message_id)
  def resolve({:U2_resolve, history, _}, user, key, "STREET", message_id), do: resolve({:U2_4, history, "STREET"}, user, key, nil, message_id)
  def resolve({:U2_resolve, history, _}, user, key, response, message_id) when response in ["LEISURE", "COMMERCE", "WORK", "GOVERN", "HOSPITAL", "TRANSPORT", "SCHOOL"], do:
    resolve({:U2_1, history, response}, user, key, nil, message_id)

  def resolve({:U2_1, history, memory}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("PERSONAL"), callback_data: "STAFF"}], [%{text: gettext("OTHER PERSON"), callback_data: "OTHER"}], [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U2_1, :initial} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("INITIAL_Q6"), new_history), user, message_id, key)
    {{:U2_1_resolve, :initial}, new_history, memory}
  end

  def resolve({:U2_1_resolve, history, memory}, user, key, "STAFF", message_id), do: resolve({:U2_3, history, memory}, user, key, nil, message_id)
  def resolve({:U2_1_resolve, history, memory}, user, key, "OTHER", message_id), do: resolve({:U2_4, history, memory}, user, key, nil, message_id)

  def resolve({:U2_4, history, memory}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}], [%{text: gettext("NO"), callback_data: "NO"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U2_4, :initial} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("INITIAL_Q7"), new_history), user, message_id, key)
    {{:U2_4_resolve, :initial}, new_history, memory}
  end

  def resolve({:U2_4_resolve, history, memory}, user, key, "YES", message_id), do: resolve({:U2_3, history, memory <> "POL"}, user, key, nil, message_id)
  def resolve({:U2_4_resolve, history, memory}, user, key, "NO", message_id), do: resolve({:U2_3, history, memory <> "PER"}, user, key, nil, message_id)

  def resolve({:U2_3, history, memory}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}], [%{text: gettext("NO"), callback_data: "NO"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U2_3, :initial} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("INITIAL_Q8"), new_history), user, message_id, key)
    {{:U2_final_resolve, :initial}, new_history, memory}
  end

  # Physical Aggresion
  def resolve({:U2_final_resolve, history, memory}, user, key, "YES", message_id) do
    if String.contains?(memory, "POL") do
      resolve({:S4, history, memory}, user, key, nil, message_id)
    else
      resolve({:S3, history, memory}, user, key, nil, message_id)
    end
  end
  # Home:
  def resolve({:U2_final_resolve, history, "HOMEPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :home_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "HOMEPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :home_pol}, history, nil}, user, key, nil, message_id)
  # Street:
  def resolve({:U2_final_resolve, history, "STREETPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :street_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "STREETPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :street_pol}, history, nil}, user, key, nil, message_id)
  # Leisure:
  def resolve({:U2_final_resolve, history, "LEISURE"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :leisure}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "LEISUREPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :leisure_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "LEISUREPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :leisure_pol}, history, nil}, user, key, nil, message_id)
  # Commerce:
  def resolve({:U2_final_resolve, history, "COMMERCE"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :commerce}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "COMMERCEPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :commerce_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "COMMERCEPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :commerce_pol}, history, nil}, user, key, nil, message_id)
  # Work:
  def resolve({:U2_final_resolve, history, "WORK"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :work}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "WORKPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :work_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "WORKPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :work_pol}, history, nil}, user, key, nil, message_id)
  # Hospital:
  def resolve({:U2_final_resolve, history, "HOSPITAL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :hospital}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "HOSPITALPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :hospital_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "HOSPITALPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :hospital_pol}, history, nil}, user, key, nil, message_id)
  # Transport:
  def resolve({:U2_final_resolve, history, "TRANSPORT"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :transport}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "TRANSPORTPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :transport_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "TRANSPORTPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :transport_pol}, history, nil}, user, key, nil, message_id)
  # School:
  def resolve({:U2_final_resolve, history, "SCHOOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :school}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "SCHOOLPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :school_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "SCHOOLPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :school_pol}, history, nil}, user, key, nil, message_id)
  # Leisure:
  def resolve({:U2_final_resolve, history, "GOVERN"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :government}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "GOVERNPER"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :government_per}, history, nil}, user, key, nil, message_id)
  def resolve({:U2_final_resolve, history, "GOVERNPOL"}, user, key, "NO", message_id), do: Manager.resolve({{:start, :government_pol}, history, nil}, user, key, nil, message_id)


  ##################################
  # U3
  ##################################



  ####################################################################
  ########################## INFORMATION #############################
  ####################################################################

  ##################################
  # I1
  ##################################

  def resolve({:I1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: "Escuela", callback_data: "I8"}, %{text: "Casa", callback_data: "I9"}]]
    TelegramWrapper.update_menu(
      keyboard,
      "Dónde ocurre el problema?",
      user,
      message_id,
      key
    )
    {:I1_resolve, history, nil}
  end

  ####################################################################
  ########################### SOLUTIONS ##############################
  ####################################################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("INITIAL_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("INITIAL_S2"), user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("INITIAL_S3"), user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("INITIAL_S4"), user, message_id, key)
  # IGNORE
  def resolve({state, history, memory}, _, _, _, _), do:  {{state, :initial}, history, memory}
end
