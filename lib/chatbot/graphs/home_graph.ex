defmodule Chatbot.HomeGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Home Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("TENANT"), callback_data: "TENANT"}, %{text: gettext("WANT TO RENT"), callback_data: "RENT"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :home} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("HOME_Q1"), new_history), user, message_id, key)
    {{:start_final_resolve, :home}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "RENT", message_id), do: resolve({:Q3, history, "RENT"}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "TENANT", message_id), do: resolve({:Q2, history, nil}, user, key, nil, message_id)
  # 2 -----
  def resolve({:Q2, _, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("LANDLORD"), callback_data: "LANDLORD"}, %{text: gettext("WORKER"), callback_data: "WORKER"}]]
    history = [{:Q2, :home}]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("HOME_Q2"), history), user, message_id, key)
    {{:Q2_resolve, :home}, history, nil}
  end

  def resolve({:Q2_resolve, history, _}, user, key, answer, message_id), do: resolve({:Q3, history, answer}, user, key, nil, message_id)
  # 3 -----
  def resolve({:Q3, history, "LANDLORD" = memory}, user, key, _, message_id), do:
    do_common_q3(history, [[%{text: gettext("PRICE MANIPULATION"), callback_data: "PRICE"}, %{text: gettext("EVICTION"), callback_data: "EVICTION"}]], memory, user, key, message_id)
  def resolve({:Q3, history, "WORKER" = memory}, user, key, _, message_id), do:
    do_common_q3(history, [[%{text: gettext("PRICE MANIPULATION"), callback_data: "PRICE"}, %{text: gettext("DENIAL"), callback_data: "DENIAL"}]], memory, user, key, message_id)
  def resolve({:Q3, history, "RENT" = memory}, user, key, _, message_id), do:
    do_common_q3(history, [[%{text: gettext("PRICE MANIPULATION"), callback_data: "PRICE"}, %{text: gettext("RENT DENIAL"), callback_data: "RENT_DENIAL"}]], memory, user, key, message_id)

  def resolve({:Q3_resolve, history, "LANDLORD"}, user, key, "PRICE", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, "WORKER"}, user, key, "PRICE", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, "RENT"}, user, key, "PRICE", message_id), do: resolve({:S5, history, nil}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, _}, user, key, "EVICTION", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, _}, user, key, "DENIAL", message_id), do: resolve({:S4, history, nil}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, _}, user, key, "RENT_DENIAL", message_id), do: resolve({:S6, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HOME_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HOME_S2"), user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HOME_S3"), user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HOME_S4"), user, message_id, key)
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HOME_S5"), user, message_id, key)
  # S6 ----
  def resolve({:S6, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HOME_S6"), user, message_id, key)

  ##################################
  # PRIVATE FUNCTIONS
  ##################################
  defp do_common_q3(history, keyboard, memory, user, key, message_id) do
    new_history = [{:Q3, :home} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("HOME_Q3"), history), user, message_id, key)
    {{:Q3_resolve, :home}, new_history, memory}
  end

end
