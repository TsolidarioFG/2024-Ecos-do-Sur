defmodule Chatbot.FaqCaResources do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the CA (Comunidad Autónoma) FAQ graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({state, history, _}, user, key, _, message_id) when state in [:start, :start_link] do
    keyboard = [
      [%{text: gettext("GENERAL"), callback_data: "Q1"}],
      [%{text: gettext("CATALUNYA"), callback_data: "Q2"}],
      [%{text: gettext("ANDALUCIA"), callback_data: "Q3"}],
      [%{text: gettext("ARAGON"), callback_data: "Q4"}],
      [%{text: gettext("ASTURIAS"), callback_data: "Q5"}],
      [%{text: gettext("CANTABRIA"), callback_data: "Q6"}],
      [%{text: gettext("CANARIAS"), callback_data: "Q7"}],
      [%{text: gettext("COM. VALENCIANA"), callback_data: "Q8"}],
      [%{text: gettext("MURCIA"), callback_data: "Q9"}],
      [%{text: gettext("GALICIA"), callback_data: "Q10"}],
      [%{text: gettext("NAVARRA"), callback_data: "Q11"}],
      [%{text: gettext("RIOJA"), callback_data: "Q12"}],
      [%{text: gettext("EUSKADI"), callback_data: "Q13"}],
      [%{text: gettext("MADRID"), callback_data: "Q14"}],
      [%{text: gettext("BALLEARS"), callback_data: "Q15"}],
      [%{text: gettext("CEUTA Y MELILLA"), callback_data: "Q16"}],
      [%{text: gettext("EXTREMADURA"), callback_data: "Q17"}],
      [%{text: gettext("CASTILLA LA MANCHA"), callback_data: "Q18"}],
      [%{text: gettext("CASTILLA LEON"), callback_data: "Q19"}],
      [%{text: gettext("BACK"), callback_data: "BACK"}]
    ]
    new_history = [{:start, :faq_ca_resources} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage(gettext("FAQ_CA_RESOURCES"), nil), user, message_id, key)
    {{:start_final_resolve, :faq_ca_resources}, new_history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "Q1", message_id), do: resolve({:GENERAL, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q2", message_id), do: resolve({:CATALUNYA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q3", message_id), do: resolve({:ANDALUCIA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q4", message_id), do: resolve({:ARAGON, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q5", message_id), do: resolve({:ASTURIAS, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q6", message_id), do: resolve({:CANTABRIA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q7", message_id), do: resolve({:CANARIAS, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q8", message_id), do: resolve({:COM_VALENCIANA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q9", message_id), do: resolve({:MURCIA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q10", message_id), do: resolve({:GALICIA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q11", message_id), do: resolve({:NAVARRA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q12", message_id), do: resolve({:RIOJA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q13", message_id), do: resolve({:EUSKADI, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q14", message_id), do: resolve({:MADRID, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q15", message_id), do: resolve({:BALLEARS, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q16", message_id), do: resolve({:CEUTA_Y_MELILLA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q17", message_id), do: resolve({:EXTREMADURA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q18", message_id), do: resolve({:CASTILLA_LA_MANCHA, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "Q19", message_id), do: resolve({:CASTILLA_LEON, history, nil}, user, key, nil, message_id)


  ##################################
  # SOLUTIONS
  ##################################
  # S1 ----
  def resolve({:GENERAL, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_CA_GENERAL"), user, message_id, key)
  # S2 ----
  def resolve({:CATALUNYA, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_CA_CATALUNYA"), user, message_id, key)
  # S3 ----
  def resolve({:ANDALUCIA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_ANDALUCIA"), user, message_id, key)
  # S4 ----
  def resolve({:ARAGON, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_CA_ARAGON"), user, message_id, key)
  # S5 ----
  def resolve({:ASTURIAS, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("FAQ_CA_ASTURIAS"), user, message_id, key)
  # S6 ----
  def resolve({:CANTABRIA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_CANTABRIA"), user, message_id, key)
  # S7 ----
  def resolve({:CANARIAS, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_CANARIAS"), user, message_id, key)
  # S8 ----
  def resolve({:COM_VALENCIANA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_COM_VALENCIANA"), user, message_id, key)
  # S9 ----
  def resolve({:MURCIA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_MURCIA"), user, message_id, key)
  # S10 ----
  def resolve({:GALICIA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_GALICIA"), user, message_id, key)
  # S11 ----
  def resolve({:NAVARRA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_NAVARRA"), user, message_id, key)
  # S12 ----
  def resolve({:RIOJA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_RIOJA"), user, message_id, key)
  # S13 ----
  def resolve({:EUSKADI, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_EUSKADI"), user, message_id, key)
  # S14 ----
  def resolve({:MADRID, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_MADRID"), user, message_id, key)
  # S15 ----
  def resolve({:BALLEARS, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_BALLEARS"), user, message_id, key)
  # S16 ----
  def resolve({:CEUTA_Y_MELILLA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_CEUTA_Y_MELILLA"), user, message_id, key)
  # S17 ----
  def resolve({:EXTREMADURA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_EXTREMADURA"), user, message_id, key)
  # S18 ----
  def resolve({:CASTILLA_LA_MANCHA, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_CASTILLA_LA_MANCHA"), user, message_id, key)
  # S19 ----
  def resolve({:CASTILLA_LEON, _, _}, user, key, _, message_id), do: CommonFunctions.do_finalize_simple(gettext("FAQ_CA_CASTILLA_LEON"), user, message_id, key)
end
