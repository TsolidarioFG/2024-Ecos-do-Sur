defmodule Chatbot.PersonSchoolGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Person-School Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("STUDENT"), callback_data: "STUDENT"}, %{text: gettext("ADULT"), callback_data: "ADULT"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :school_per} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_PER_Q1"), new_history), user, message_id, key)
    {{:start_final_resolve, :school_per}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, answer, message_id), do: resolve({:U1, history, answer}, user, key, nil, message_id)
  # 2 -----
  def resolve({:U1, history, "STUDENT" = memory}, user, key, _, message_id), do:
    do_common_u1(history, [[%{text: gettext("BULLYING"), callback_data: "BULLYING"}, %{text: gettext("VIOLENCE"), callback_data: "VIOLENCE"}], [%{text: gettext("SEXUAL_HARASSMENT"), callback_data: "SEXUAL"}]], memory, user, key, message_id)
    def resolve({:U1, history, "ADULT" = memory}, user, key, _, message_id), do:
    do_common_u1(history, [[%{text: gettext("VIOLENCE"), callback_data: "VIOLENCE"}], [%{text: gettext("SEXUAL_HARASSMENT"), callback_data: "SEXUAL"}]], memory, user, key, message_id)


  def resolve({:U1_resolve, history, "STUDENT"}, user, key, "BULLYING", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, "STUDENT"}, user, key, "SEXUAL", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, "STUDENT"}, user, key, "VIOLENCE", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, "ADULT"}, user, key, "SEXUAL", message_id), do: resolve({:S4, history, nil}, user, key, nil, message_id)
  def resolve({:U1_resolve, history, "ADULT"}, user, key, "VIOLENCE", message_id), do: resolve({:S5, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_PER_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_PER_S2"), user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_PER_S3"), user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_PER_S4"), user, message_id, key)
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_PER_S5"), user, message_id, key)

  ##################################
  # PRIVATE FUNCTIONS
  ##################################
  defp do_common_u1(history, keyboard, memory, user, key, message_id) do
    new_history = [{:Q3, :school_per} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_PER_Q2"), history), user, message_id, key)
    {{:U1_resolve, :school_per}, new_history, memory}
  end

end
