defmodule Chatbot.StateManager do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  require Logger
  import ChatBot.Gettext

  ####################################################################
  ############################# START ################################
  ####################################################################
  def resolve(:start, user, key, _, nil) do
    keyboard = [[%{text: "URGENTE", callback_data: "U1"}, %{text: "INFORMACIÓN", callback_data: "I1"}]]
    TelegramWrapper.send_message(key, user, gettext("Language has been set."))
    TelegramWrapper.send_menu(
      keyboard,
      "Estás en una situación de emergenia o solo buscas información?",
      user,
      key
    )
    :start_resolve
  end
  def resolve(:start, user, key, _, message_id) do
    keyboard = [[%{text: "URGENTE", callback_data: "U1"}, %{text: "INFORMACIÓN", callback_data: "I1"}]]
    TelegramWrapper.update_menu(
      keyboard,
      "Estás en una situación de emergenia o solo buscas información?",
      user,
      message_id,
      key
    )
    :start_resolve
  end

  def resolve(:start_resolve, user, key, "U1", message_id), do: resolve(:U1, user, key, nil, message_id)
  def resolve(:start_resolve, user, key, "I1", message_id), do: resolve(:I1, user, key, nil, message_id)

  ####################################################################
  ############################ URGENT ################################
  ####################################################################

  ##################################
  # U1
  ##################################

  def resolve(:U1, user, key, _, message_id) do
    keyboard = [[%{text: "YO", callback_data: "U2"}, %{text: "OTRO", callback_data: "U3"}, %{text: "ATRÁS", callback_data: "BACK"}]]
        TelegramWrapper.update_menu(
          keyboard,
          "Quién necesita ayuda, tu u otra persona?",
          user,
          message_id,
          key
        )
        :U1_resolve
  end

  def resolve(:U1_resolve, user, key, "U2", message_id), do: resolve(:U2, user, key, nil, message_id)
  def resolve(:U1_resolve, user, key, "U3", message_id), do: resolve(:U3, user, key, nil, message_id)
  def resolve(:U1_resolve, user, key, "BACK", message_id), do: resolve(:start, user, key, nil, message_id)
  def resolve(:U1_resolve, user, key, "CONTINUE", message_id), do: resolve(:U1, user, key, nil, message_id)

  ##################################
  # U2
  ##################################

  def resolve(:U2, user, key, _, message_id) do
    keyboard = [[%{text: "SÍ", callback_data: "S1"}, %{text: "NO", callback_data: "U4"}, %{text: "ATRÁS", callback_data: "BACK"}]]
        TelegramWrapper.update_menu(
          keyboard,
          "Estás en peligro?",
          user,
          message_id,
          key
        )
        :U2_resolve
  end

  def resolve(:U2_resolve, user, key, "S1", message_id), do: resolve(:S1, user, key, nil, message_id)
  def resolve(:U2_resolve, user, key, "U4", message_id), do: resolve(:U3, user, key, nil, message_id)
  def resolve(:U2_resolve, user, key, "BACK", message_id), do: resolve(:U1, user, key, nil, message_id)
  def resolve(:U2_resolve, user, key, "CONTINUE", message_id), do: resolve(:U2, user, key, nil, message_id)

  ##################################
  # U3
  ##################################

  def resolve(:U3, user, key, _, message_id) do
    keyboard = [[%{text: "SÍ", callback_data: "S1"}, %{text: "NO", callback_data: "U4"}, %{text: "ATRÁS", callback_data: "BACK"}]]
        TelegramWrapper.update_menu(
          keyboard,
          "Están o está en peligro?",
          user,
          message_id,
          key
        )
        :U3_resolve
  end

  def resolve(:U3_resolve, user, key, "S1", message_id), do: resolve(:S1, user, key, nil, message_id)
  def resolve(:U3_resolve, user, key, "U4", message_id), do: resolve(:U3, user, key, nil, message_id)
  def resolve(:U3_resolve, user, key, "BACK", message_id), do: resolve(:U1, user, key, nil, message_id)
  def resolve(:U3_resolve, user, key, "CONTINUE", message_id), do: resolve(:U3, user, key, nil, message_id)

  ####################################################################
  ########################## INFORMATION #############################
  ####################################################################

  ##################################
  # I1
  ##################################

  def resolve(:I1, user, key, _, message_id) do
    keyboard = [[%{text: "Escuela", callback_data: "I8"}, %{text: "Casa", callback_data: "I9"}]]
    TelegramWrapper.update_menu(
      keyboard,
      "Dónde ocurre el problema?",
      user,
      message_id,
      key
    )
    :I1_resolve
  end

  ####################################################################
  ########################### SOLUTIONS ##############################
  ####################################################################

  ##################################
  # S1
  ##################################

  def resolve(:S1, user, key, _, message_id) do
        TelegramWrapper.update_menu(
          [],
          "Solución 1",
          user,
          message_id,
          key
        )
        :solved
  end
end
