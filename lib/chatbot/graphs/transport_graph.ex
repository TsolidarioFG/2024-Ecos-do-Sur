defmodule Chatbot.TransportGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext


  @doc """
  This module represents the Transport Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("PUBLIC"), callback_data: "PUBLIC"}, %{text: gettext("PRIVATE"), callback_data: "PRIVATE"}],
                [%{text: gettext("AMBULANCE"), callback_data: "AMBULANCE"}, %{text: gettext("SCHOOL BUS"), callback_data: "SCHOOL_BUS"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :transport} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("TRANSPORT_Q1"), new_history), user, message_id, key)
    {{:start_final_resolve, :transport}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, answer, message_id), do: resolve({:U1, history, answer}, user, key, nil, message_id)
  # 2 -----
  def resolve({:U1, history, memory}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("DENIAL"), callback_data: "DENIAL"}, %{text: gettext("PRICE MANIPULATION"), callback_data: "PRICE"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:U1, :transport} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("TRANSPORT_Q2"), new_history), user, message_id, key)
    {{:U1_resolve, :transport}, new_history, memory}
  end

  def resolve({:U1_resolve, history, "PUBLIC"}, user, key, "DENIAL", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, "PRIVATE"}, user, key, "DENIAL", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, "SCHOOL_BUS"}, user, key, "DENIAL", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, "AMBULANCE"}, user, key, "DENIAL", message_id), do: resolve({:S4, history, nil}, user, key, nil, message_id)

  def resolve({:U1_resolve, history, "AMBULANCE"}, user, key, "PRICE", message_id), do: resolve({:S5, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, _}, user, key, "PRICE", message_id), do: resolve({:S6, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("TRANSPORT_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("TRANSPORT_S2"), user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("TRANSPORT_S3"), user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("TRANSPORT_S4"), user, message_id, key)
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("TRANSPORT_S5"), user, message_id, key)
  # S6 ----
  def resolve({:S6, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("TRANSPORT_S6"), user, message_id, key)
  # IGNORE
  def resolve({state, history, memory}, _, _, _, _), do:  {{state, :transport}, history, memory}
end
