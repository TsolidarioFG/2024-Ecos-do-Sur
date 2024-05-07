defmodule Chatbot.CommonFunctions do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  def do_finalize_simple(text, user, message_id, key) do
    TelegramWrapper.update_menu(text, user, message_id, key)
    {:solved, nil, nil}
  end

  def do_finalize_complex(text, dest, mod, user, message_id, key) do
    TelegramWrapper.update_menu(text, user, message_id, key)
    mod.resolve({dest, nil, nil}, user, key, nil, message_id)
  end
end
