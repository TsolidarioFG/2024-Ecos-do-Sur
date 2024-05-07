defmodule Chatbot.PersonWorkGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Person-Work Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("BAD BEHAVIOR"), callback_data: "BEHAVIOR"}, %{text: gettext("THEFT"), callback_data: "THEFT"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :work_per} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("WORK_PER_Q1"), new_history), user, message_id, key)
    {{:start_final_resolve, :work_per}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "BEHAVIOR", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "THEFT", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("WORK_PER_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("WORK_PER_S2"), user, message_id, key)
end
