defmodule Chatbot.TelegramWrapper do
  def send_message(key, chat_id, text) do
      Telegram.Api.request(key, "sendMessage", chat_id: chat_id, text: text)
  end

  def answer_callback_query(key, query_id) do
    Telegram.Api.request(key, "answerCallbackQuery", callback_query_id: query_id)
  end

  # Updates a message with new text and keyboard markup
  def update_menu(keyboard, text, chat_id, message_id, key) do
    keyboard_markup = %{inline_keyboard: keyboard}
    Telegram.Api.request(key, "editMessageText", chat_id: chat_id, message_id: message_id, text: text, reply_markup: {:json, keyboard_markup}, parse_mode: "markdown")
  end

  # Sends a new message with keyboard markup
  def send_menu(keyboard, message, chat_id, key) do
    keyboard_markup = %{inline_keyboard: keyboard}
    Telegram.Api.request(key, "sendMessage", chat_id: chat_id, text: message, reply_markup: {:json, keyboard_markup})
  end
end
