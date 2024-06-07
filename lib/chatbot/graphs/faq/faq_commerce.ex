defmodule Chatbot.FaqCommerce do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Commerce FAQ graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("FAQ_COMMERCE_Q1"), callback_data: "Q1"}],
                [%{text: gettext("FAQ_COMMERCE_Q2"), callback_data: "Q2"}],
                [%{text: gettext("FAQ_COMMERCE_Q3"), callback_data: "Q3"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :faq_commerce} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("FAQ_COMMERCE_TITLE"), nil), user, message_id, key)
    {{:start_final_resolve, :faq_commerce}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "Q1", message_id), do:  resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q2", message_id), do:  resolve({:S2, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q3", message_id), do:  resolve({:S3, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_COMMERCE_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_COMMERCE_S2"), user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_COMMERCE_S3"), user, message_id, key)
end
