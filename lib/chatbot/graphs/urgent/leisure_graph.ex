defmodule Chatbot.LeisureGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Leisure Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("ENTRANCE DENIAL"), callback_data: "ENTRANCE"}], [%{text: gettext("PRICE MANIPULATION"), callback_data: "PRICE"}],
                [%{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:start, :leisure} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("LEISURE_Q1"), new_history), user, message_id, key)
    {{:start_final_resolve, :leisure}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "ENTRANCE", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "PRICE", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)

  ##################################
  # ENTRANCE
  ##################################
  # 2 -----
  def resolve({:EN, history, _}, user, key, _, _) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:EN, :leisure} | history]
    TelegramWrapper.send_menu(keyboard, HistoryFormatting.buildMessage(gettext("LEISURE_Q2"), new_history), user, key)
    {{:EN_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_resolve, history, _}, user, key, "YES", message_id), do: resolve({:EN_1, history, nil}, user, key, nil, message_id)
  def resolve({:EN_resolve, history, _}, user, key, "NO", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)
  # 3 -----
  def resolve({:EN_1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:EN_1, :leisure} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("LEISURE_Q3"), new_history), user, message_id, key)
    {{:EN_1_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_1_resolve, history, _}, user, key, "YES", message_id), do: resolve({:S4, history, nil}, user, key, nil, message_id)
  def resolve({:EN_1_resolve, history, _}, user, key, "NO", message_id), do: resolve({:EN_2_1, history, nil}, user, key, nil, message_id)
  # 4 -----
  def resolve({:EN_2, history, _}, user, key, _, _) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:EN_2, :leisure} | history]
    TelegramWrapper.send_menu(keyboard, HistoryFormatting.buildMessage(gettext("LEISURE_Q4"), new_history), user, key)
    {{:EN_2_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_2_1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: gettext("YES"), callback_data: "YES"}, %{text: gettext("NO"), callback_data: "NO"}, %{text: gettext("BACK"), callback_data: "BACK"}]]
    new_history = [{:EN_2, :leisure} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("LEISURE_Q4"), new_history), user, message_id, key)
    {{:EN_2_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_2_resolve, history, _}, user, key, "YES", message_id), do: resolve({:S5, history, nil}, user, key, nil, message_id)
  def resolve({:EN_2_resolve, history, _}, user, key, "NO", message_id), do: resolve({:S7, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1-Q2 -
  def resolve({:S1, history, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(gettext("LEISURE_S1"), user, message_id, key)
    resolve({:EN, history, nil}, user, key, nil, message_id)
  end

  # S2 ----
  def resolve({:S2, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_complex(gettext("LEISURE_S2"), :S6, __MODULE__, user, message_id, key)
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("LEISURE_S3"), user, message_id, key)
  # S4-Q4 -
  def resolve({:S4, history, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(gettext("LEISURE_S4"), user, message_id, key)
    resolve({:EN_2, history, nil}, user, key, nil, message_id)
  end
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_complex(gettext("LEISURE_S5"), :S6, __MODULE__, user, message_id, key)
  # S6 ----
  def resolve({:S6, _, _}, user, key, _, _) do
    TelegramWrapper.send_message(key, user, gettext("LEISURE_S6"))
    {:solved, nil, nil}
  end
  # S7 ----
  def resolve({:S7, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("LEISURE_S7"), user, message_id, key)
  # IGNORE
  def resolve({state, history, memory}, _, _, _, _), do:  {{state, :leisure}, history, memory}
end
