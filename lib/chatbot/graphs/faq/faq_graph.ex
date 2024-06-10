defmodule Chatbot.FaqGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
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
    keyboard = [[%{text: gettext("CHATBOT_Q"), callback_data: "CHATBOT_INFORMATION"}],
                [%{text: gettext("ECOS_Q"), callback_data: "ECOS_INFORMATION"}],
                [%{text: gettext("HATE_SPEECH_DEF_Q"), callback_data: "HATE_SPEECH_DEF"}],
                [%{text: gettext("HATE_SPEECH_RS_Q"), callback_data: "HATE_SPEECH_RS"}],
                [%{text: gettext("HEALTHCARE"), callback_data: "HEALTHCARE"}],
                [%{text: gettext("RESOURCES"), callback_data: "RESOURCES"}],
                [%{text: gettext("COMMERCE_FAQ"), callback_data: "COMMERCE"}],
                [%{text: gettext("WORK_FAQ"), callback_data: "WORK"}],
                [%{text: gettext("RENT_FAQ"), callback_data: "RENT"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :faq} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("FAQ"), nil), user, message_id, key)
    {{:start_final_resolve, :faq}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "HEALTHCARE", message_id), do:  Manager.resolve({{:start, :faq_healthcare}, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "RESOURCES", message_id), do:  Manager.resolve({{:start, :faq_ca_resources}, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "COMMERCE", message_id), do:  Manager.resolve({{:start, :faq_commerce}, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "WORK", message_id), do:  Manager.resolve({{:start, :faq_work}, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "RENT", message_id), do:  Manager.resolve({{:start, :faq_rent}, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "CHATBOT_INFORMATION", message_id), do:  resolve({:CHATBOT, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "ECOS_INFORMATION", message_id), do:  resolve({:ECOS, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "HATE_SPEECH_DEF", message_id), do:  resolve({:HS_DEF, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "HATE_SPEECH_RS", message_id), do:  resolve({:HS_RS, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # CHATBOT_INFORMATION ----
  def resolve({:CHATBOT, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("CHATBOT_INFORMATION"), user, message_id, key)
  # ECOS_INFORMATION ----
  def resolve({:ECOS, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("ECOS_INFORMATION"), user, message_id, key)
  # HATE_SPEECH_DEF ----
  def resolve({:HS_DEF, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HATE_SPEECH_DEF"), user, message_id, key)
  # HATE_SPEECH_RS ----
  def resolve({:HS_RS, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("HATE_SPEECH_RS"), user, message_id, key)
end
