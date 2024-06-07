defmodule Chatbot.TelegramWrapper do
  require Logger
  def send_message(key, chat_id, text) do
      {_, res} = Telegram.Api.request(key, "sendMessage", chat_id: chat_id, text: text, parse_mode: "markdown")
      GenServer.cast(self(), {:last_message, res["message_id"]})
  end

  def answer_callback_query(key, query_id) do
    Telegram.Api.request(key, "answerCallbackQuery", callback_query_id: query_id)
  end

  def delete_message(key, chat_id, message_id) do
    Telegram.Api.request(key, "deleteMessage", chat_id: chat_id, message_id: message_id)
  end

  # Updates a message with new text and keyboard markup
  def update_menu( text, chat_id, message_id, key) do
    keyboard_markup = %{inline_keyboard: []}
    Telegram.Api.request(key, "editMessageText", chat_id: chat_id, message_id: message_id, text: text, reply_markup: {:json, keyboard_markup}, parse_mode: "markdown")
  end
  def update_menu(keyboard, text, chat_id, message_id, key) do
    keyboard_markup = %{inline_keyboard: keyboard}
    Telegram.Api.request(key, "editMessageText", chat_id: chat_id, message_id: message_id, text: text, reply_markup: {:json, keyboard_markup}, parse_mode: "markdown")
  end

  # Sends a new message with keyboard markup
  def send_menu(keyboard, message, chat_id, key) do
    keyboard_markup = %{inline_keyboard: keyboard}
    {_, res} = Telegram.Api.request(key, "sendMessage", chat_id: chat_id, text: message, reply_markup: {:json, keyboard_markup}, parse_mode: "markdown")
    GenServer.cast(self(), {:last_message, res["message_id"]})
  end

  def send_image(image_path, chat_id, key) do
    Telegram.Api.request(key, "sendPhoto", chat_id: chat_id, photo: {:file, image_path})
  end
end
