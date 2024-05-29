defmodule Chatbot.FaqGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.Manager
  import ChatBot.Gettext

  @doc """
  This module represents the FAQ graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("HEALTHCARE"), callback_data: "HEALTHCARE"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :faq} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("FAQ"), nil), user, message_id, key)
    {{:start_final_resolve, :faq}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "HEALTHCARE", message_id), do:  Manager.resolve({{:start, :faq_healthcare}, history, nil}, user, key, nil, message_id)
end
