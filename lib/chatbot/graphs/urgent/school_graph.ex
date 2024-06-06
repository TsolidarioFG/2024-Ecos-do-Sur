defmodule Chatbot.SchoolGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the School Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("TEACHER"), callback_data: "TEACHER"}, %{text: gettext("CONTENT"), callback_data: "CONTENT"}],
                [%{text: gettext("ACTIVITIES"), callback_data: "ACTIVITIES"}, %{text: gettext("OTHER"), callback_data: "OTHER"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q1"), new_history), user, message_id, key)
    {{:start_final_resolve, :school}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "TEACHER", message_id), do: resolve({:TE_Q7, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "CONTENT", message_id), do: resolve({:S9, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "ACTIVITIES", message_id), do: resolve({:AC, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "OTHER", message_id), do: resolve({:S10, history, nil}, user, key, nil, message_id)

  ##################################
  # TEACHER U1
  ##################################
  # 7 -----
  def resolve({:TE_Q7, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("PARENT"), callback_data: "PARENT"}, %{text: gettext("STUDENT"), callback_data: "STUDENT"}],
    [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:TE_Q7, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q7"), new_history), user, message_id, key)
    {{:TE_Q7_resolve, :school}, new_history, nil}
  end

  def resolve({:TE_Q7_resolve, history, _}, user, key, "PARENT", message_id), do: resolve({:S19, history, nil}, user, key, nil, message_id)
  def resolve({:TE_Q7_resolve, history, _}, user, key, "STUDENT", message_id), do: resolve({:TE, history, nil}, user, key, nil, message_id)
  # 2 -----
  def resolve({:TE, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("TEACHER"), callback_data: "TEACHER"}, %{text: gettext("FAMILY"), callback_data: "FAMILY"}],
                [%{text: gettext("BOTH"), callback_data: "BOTH"}, %{text: gettext("NO"), callback_data: "NO"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:TE, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q2"), new_history), user, message_id, key)
    {{:TE_resolve, :school}, new_history, nil}
  end

  def resolve({:TE_resolve, history, _}, user, key, "TEACHER", message_id), do: resolve({:TE_1, history, "TEACHER"}, user, key, nil, message_id)
  def resolve({:TE_resolve, history, _}, user, key, "FAMILY", message_id), do: resolve({:TE_1, history, "FAMILY"}, user, key, nil, message_id)
  def resolve({:TE_resolve, history, _}, user, key, "BOTH", message_id), do: resolve({:BO, history, nil}, user, key, nil, message_id)
  def resolve({:TE_resolve, history, _}, user, key, "NO", message_id), do: resolve({:S8, history, nil}, user, key, nil, message_id)
  # 3 ----- Family / Teacher
  def resolve({:TE_1, history, memory}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:TE_1, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q3"), new_history), user, message_id, key)
    {{:TE_1_resolve, :school}, new_history, memory}
  end

  def resolve({:TE_1_resolve, history, "FAMILY"}, user, key, "YES", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:TE_1_resolve, history, "FAMILY"}, user, key, "NO", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)
  def resolve({:TE_1_resolve, history, "TEACHER"}, user, key, "YES", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)
  def resolve({:TE_1_resolve, history, "TEACHER"}, user, key, "NO", message_id), do: resolve({:S4, history, nil}, user, key, nil, message_id)
  # 3 ----- Both
  def resolve({:BO, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:BO, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q3"), new_history), user, message_id, key)
    {{:BO_resolve, :school}, new_history, nil}
  end

  def resolve({:BO_resolve, history, _}, user, key, "YES", message_id), do: resolve({:S7, history, nil}, user, key, nil, message_id)
  def resolve({:BO_resolve, history, _}, user, key, "NO", message_id), do: resolve({:S6, history, nil}, user, key, nil, message_id)

  ##################################
  # ACTIVITIES or SERVICES
  ##################################
  # 4 -----
  def resolve({:AC, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("SECRETARY"), callback_data: "SECRETARY"}, %{text: gettext("EXTRACURRICULAR"), callback_data: "EXTRACURRICULAR"}],
                [%{text: gettext("CANTEEN"), callback_data: "CANTEEN"}, %{text: gettext("AMPA"), callback_data: "AMPA"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:AC, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q4"), new_history), user, message_id, key)
    {{:AC_resolve, :school}, new_history, nil}
  end

  def resolve({:AC_resolve, history, _}, user, key, "SECRETARY", message_id), do: resolve({:AC_SEC, history, "SEC"}, user, key, nil, message_id)
  def resolve({:AC_resolve, history, _}, user, key, "EXTRACURRICULAR", message_id), do: resolve({:AC_EX, history, "EX"}, user, key, nil, message_id)
  def resolve({:AC_resolve, history, _}, user, key, "CANTEEN", message_id), do: resolve({:AC_CA, history, "CA"}, user, key, nil, message_id)
  def resolve({:AC_resolve, history, _}, user, key, "AMPA", message_id), do: resolve({:S18, history, nil }, user, key, nil, message_id)
  # 5 -----
  # U2 --
  def resolve({:AC_SEC, history, "SEC"}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("UNEQUAL TREATMENT"), callback_data: "UNEQUAL"}, %{text: gettext("TUITION"), callback_data: "TUITION"}]]
    new_history = [{:AC_SEC, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q5"), new_history), user, message_id, key)
    {{:AC_final_resolve, :school}, new_history, "SEC"}
  end
  # U3 --
  def resolve({:AC_EX, history, "EX"}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("UNEQUAL TREATMENT"), callback_data: "UNEQUAL"}, %{text: gettext("PRICE MODIFICATION"), callback_data: "PRICE"}],
                [%{text: gettext("DENIAL OF SERVICE"), callback_data: "DENIAL"}]]
    new_history = [{:AC_EX, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q5"), new_history), user, message_id, key)
    {{:AC_final_resolve, :school}, new_history, "EX"}
  end
  # U4 --
  def resolve({:AC_CA, history, "CA"}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("DIET"), callback_data: "DIET"}, %{text: gettext("PRICE MODIFICATION"), callback_data: "PRICE"}],
                [%{text: gettext("DENIAL OF SERVICE"), callback_data: "DENIAL"}]]
    new_history = [{:AC_CA, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q5"), new_history), user, message_id, key)
    {{:AC_final_resolve, :school}, new_history, "CA"}
  end

  def resolve({:AC_final_resolve, history, _}, user, key, "UNEQUAL", message_id), do: resolve({:S11, history, nil}, user, key, nil, message_id)
  def resolve({:AC_final_resolve, history, _}, user, key, "TUITION", message_id), do: resolve({:S12, history, nil}, user, key, nil, message_id)
  def resolve({:AC_final_resolve, history, _}, user, key, "PRICE", message_id), do: resolve({:S16, history, nil}, user, key, nil, message_id)
  def resolve({:AC_final_resolve, history, _}, user, key, "DIET", message_id), do: resolve({:DI, history, nil}, user, key, nil, message_id)
  def resolve({:AC_final_resolve, history, "CA"}, user, key, "DENIAL", message_id), do: resolve({:S15, history, nil}, user, key, nil, message_id)
  def resolve({:AC_final_resolve, history, "EX"}, user, key, "DENIAL", message_id), do: resolve({:S17, history, nil}, user, key, nil, message_id)
  # 5 -----
  def resolve({:DI, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("RELIGION OR PHILOSOPHY"), callback_data: "BELIEFS"}, %{text: gettext("MEDICAL NEED"), callback_data: "MEDICAL"}]]
    new_history = [{:DI, :school} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("SCHOOL_Q6"), new_history), user, message_id, key)
    {{:DI_resolve, :school}, new_history, nil}
  end

  def resolve({:DI_resolve, history, _}, user, key, "BELIEFS", message_id), do: resolve({:S13, history, nil}, user, key, nil, message_id)
  def resolve({:DI_resolve, history, _}, user, key, "MEDICAL", message_id), do: resolve({:S14, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:S1, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_complex(gettext("SCHOOL_S1"), :S5, __MODULE__, user, message_id, key)
  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_complex(gettext("SCHOOL_S2"), :S5, __MODULE__, user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_complex(gettext("SCHOOL_S3"), :S5, __MODULE__, user, message_id, key)
  # S4 ----
  def resolve({:S4, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_complex(gettext("SCHOOL_S4"), :S5, __MODULE__, user, message_id, key)
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, _) do
    TelegramWrapper.send_message(key, user, gettext("SCHOOL_S5"))
    {:solved, nil, nil}
  end
  # S6 ----
  def resolve({:S6, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S6"), user, message_id, key)
  # S7 ----
  def resolve({:S7, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S7"), user, message_id, key)
  # S8 ----
  def resolve({:S8, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S8"), user, message_id, key)
  # S9 ----
  def resolve({:S9, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S9"), user, message_id, key)
  # S10 ----
  def resolve({:S10, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S10"), user, message_id, key)
  # S11 ----
  def resolve({:S11, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S11"), user, message_id, key)
  # S12 ----
  def resolve({:S12, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S12"), user, message_id, key)
  # S13 ----
  def resolve({:S13, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S13"), user, message_id, key)
  # S14 ----
  def resolve({:S14, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S14"), user, message_id, key)
  # S15 ----
  def resolve({:S15, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S15"), user, message_id, key)
  # S16 ----
  def resolve({:S16, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S16"), user, message_id, key)
  # S17 ----
  def resolve({:S17, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("SCHOOL_S17"), user, message_id, key)
  # S18 ----
  def resolve({:S18, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("SCHOOL_S18"), user, message_id, key)
  # S18 ----
  def resolve({:S19, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("SCHOOL_S19"), user, message_id, key)
  # IGNORE
  def resolve({state, history, memory}, _, _, _, _), do:  {{state, :school}, history, memory}
end
