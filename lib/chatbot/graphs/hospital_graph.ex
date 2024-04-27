defmodule Chatbot.HospitalGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Hospital Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, _, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("SERVICE DENIAL"), callback_data: "DENIAL"}]]
    history = [{:start, :hospital}]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("HOSPITAL_Q1"), history), user, message_id, key)
    {{:start_final_resolve, :hospital}, history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "DENIAL", message_id), do: resolve({:U1, history, nil}, user, key, nil, message_id)
  ##################################
  # SERVICE DENIAL
  ##################################
  # 2 -----
  def resolve({:U1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("HOSPITAL"), callback_data: "HOSPITAL"}, %{text: gettext("CLINIC"), callback_data: "CLINIC"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U1, :hospital} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("HOSPITAL_Q2"), new_history), user, message_id, key)
    {{:U1_resolve, :hospital}, new_history, nil}
  end

  def resolve({:U1_resolve, history, _}, user, key, "HOSPITAL", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, _}, user, key, "CLINIC", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)
  # 3 -----
  def resolve({:U2, history, _}, user, key, _, _) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U2, :hospital} | history]
    TelegramWrapper.send_menu(keyboard, HistoryFormatting.buildMessage(gettext("HOSPITAL_Q3"), new_history), user, key)
    {{:EN_resolve, :hospital}, new_history, nil}
  end

  def resolve({:EN_resolve, history, _}, user, key, "YES", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)
  def resolve({:EN_resolve, history, _}, user, key, "NO", message_id), do: resolve({:S4_1, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1-Q3 -
  def resolve({:S1, history, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(gettext("HOSPITAL_S1"), user, message_id, key)
    resolve({:U2, history, nil}, user, key, nil, message_id)
  end
  # S2-Q3 -
  def resolve({:S2, history, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(gettext("HOSPITAL_S2"), user, message_id, key)
    resolve({:U2, history, nil}, user, key, nil, message_id)
  end
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_complex(gettext("HOSPITAL_S3"), :S4, __MODULE__, user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, _) do
    TelegramWrapper.send_message(key, user, gettext("HOSPITAL_S4"))
    {:solved, nil, nil}
  end
  # S4-1 -
  def resolve({:S4_1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HOSPITAL_S4"), user, message_id, key)
  # IGNORE
  def resolve({state, history, memory}, _, _, _, _), do:  {{state, :hospital}, history, memory}
end
