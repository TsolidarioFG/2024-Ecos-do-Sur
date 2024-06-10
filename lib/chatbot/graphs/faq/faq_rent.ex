defmodule Chatbot.FaqRent do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  alias Chatbot.Manager
  import ChatBot.Gettext

  @doc """
  This module represents the Rent FAQ graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("FAQ_RENT_Q1"), callback_data: "Q1"}],
                [%{text: gettext("FAQ_RENT_Q2"), callback_data: "Q2"}],
                [%{text: gettext("FAQ_RENT_Q3"), callback_data: "Q3"}],
                [%{text: gettext("FAQ_RENT_Q4"), callback_data: "Q4"}],
                [%{text: gettext("FAQ_RENT_Q5"), callback_data: "Q5"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :faq_rent} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("FAQ_RENT_TITLE"), nil), user, message_id, key)
    {{:start_final_resolve, :faq_rent}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "Q1", message_id), do:  resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q2", message_id), do:  resolve({:S2, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q3", message_id), do:  resolve({:S3, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q4", message_id), do:  resolve({:S4, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q5", message_id), do:  resolve({:S5, history, nil}, user, key, nil, message_id)

  ##################################
  # FAQ LINKING
  ##################################
  def resolve({:L1, _, _}, user, key, _, _) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}], [%{text: gettext("NO"), callback_data: "NO"}]]
    TelegramWrapper.send_menu(keyboard, HistoryFormatting.buildMessage(gettext("FAQ_RENT_Q6"), nil), user, key)
    {{:L1_resolve, :home}, nil, nil}
  end

  def resolve({:L1_resolve, history, _}, user, key, "YES", message_id), do: Manager.resolve({{:start_link, :faq_ca_resources}, history, nil}, user, key, nil, message_id)
  def resolve({:L1_resolve, _, _}, user, key, "NO", message_id) do
    TelegramWrapper.delete_message(key, user, message_id)
    {:solved, nil, nil}
  end

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_RENT_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_RENT_S2"), user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_RENT_S3"), user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_RENT_S4"), user, message_id, key)
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(gettext("FAQ_RENT_S5"), user, message_id, key)
    resolve({:L1, nil, nil}, user, key, nil, message_id)
  end
end
