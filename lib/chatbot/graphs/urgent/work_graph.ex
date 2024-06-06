defmodule Chatbot.WorkGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Work/Job Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("EMPLOYEE"), callback_data: "EMPLOYEE"}], [%{text: gettext("JOB CANDIDATE"), callback_data: "CANDIDATE"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :work} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("WORK_Q1"), new_history), user, message_id, key)
    {{:start_final_resolve, :work}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "EMPLOYEE", message_id), do: resolve({:EM, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "CANDIDATE", message_id), do: resolve({:Q3, history, "CANDIDATE"}, user, key, nil, message_id)

  ##################################
  # EMPLOYEE
  ##################################
  # 2 -----
  def resolve({:EM, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("BOSS"), callback_data: "BOSS"}, %{text: gettext("WORKER"), callback_data: "WORKER"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:EM, :work} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("WORK_Q2"), history), user, message_id, key)
    {{:EM_resolve, :work}, new_history, nil}
  end

  def resolve({:EM_resolve, history, _}, user, key, answer, message_id), do: resolve({:Q3, history, answer}, user, key, nil, message_id)
  # 4 -----
  def resolve({:EM_1, history, memory}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("TASK DISTRIBUTION"), callback_data: "TASK"}], [%{text: gettext("MARGINALIZATION"), callback_data: "MARGINALIZATION"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:EM_1, :work} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("WORK_Q4"), history), user, message_id, key)
    {{:EM_1_resolve, :work}, new_history, memory}
  end

  def resolve({:EM_1_resolve, history, _}, user, key, "TASK", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)
  def resolve({:EM_1_resolve, history, _}, user, key, "MARGINALIZATION", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)

  ##################################
  # BOTH
  ##################################
  # 3 -----
  def resolve({:Q3, history, "CANDIDATE" = memory}, user, key, _, message_id), do:
    do_common_q3(history, [[ %{text: gettext("REJECTION"), callback_data: "REJECTION"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]], memory, user, key, message_id)

  def resolve({:Q3, history, "WORKER" = memory}, user, key, _, message_id), do:
    do_common_q3(history, [[%{text: gettext("DISTINCTIVE TREATMENT"), callback_data: "TREATMENT"}],[%{text: gettext("FORCED WORK"), callback_data: "FORCED"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]], memory, user, key, message_id)

  def resolve({:Q3, history, "BOSS" = memory}, user, key, _, message_id), do:
    do_common_q3(history, [[%{text: gettext("EXPLOITATION"), callback_data: "EXPLOITATION"}], [%{text: gettext("DISTINCTIVE TREATMENT"), callback_data: "TREATMENT"}],[%{text: gettext("FORCED WORK"), callback_data: "FORCED"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]], memory, user, key, message_id)


  def resolve({:Q3_resolve, history, "CANDIDATE"}, user, key, "REJECTION", message_id), do: resolve({:S5, history, nil}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, "BOSS"}, user, key, "EXPLOITATION", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, memory}, user, key, "TREATMENT", message_id) when memory in ["BOSS", "WORKER"], do: resolve({:EM_1, history, memory}, user, key, nil, message_id)
  def resolve({:Q3_resolve, history, memory}, user, key, "FORCED", message_id) when memory in ["BOSS", "WORKER"], do: resolve({:S4, history, memory}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("WORK_S1"), user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("WORK_S2"), gettext("WORK_S2_1"), user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("WORK_S3"), user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("WORK_S4"), user, message_id, key)
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("WORK_S5"), user, message_id, key)

  ##################################
  # PRIVATE FUNCTIONS
  ##################################
  defp do_common_q3(history, keyboard, memory, user, key, message_id) do
    new_history = [{:Q3, :work} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("WORK_Q3"), history), user, message_id, key)
    {{:Q3_resolve, :work}, new_history, memory}
  end
end
