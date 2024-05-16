defmodule ManagerTest do
  use ExUnit.Case
  doctest Chatbot.Manager

  test "init graph" do
    new_state = Chatbot.Manager.resolve({{:start, :initial}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :initial}, [{:start, :initial}], nil}
  end

  test "back" do
    new_state = Chatbot.Manager.resolve({{:U1_new_resolve, :initial}, [{:U1_new, :initial}, {:start, :initial}], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), "BACK", 1)
    assert new_state == {{:start_final_resolve, :initial}, [{:start, :initial}], nil}
  end

  test "continue" do
    new_state = Chatbot.Manager.resolve({{:U1_new_resolve, :initial}, [{:U1_new, :initial}, {:start, :initial}], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), "CONTINUE", 1)
    assert new_state == {{:U1_new_resolve, :initial}, [{:U1_new, :initial}, {:start, :initial}], nil}
  end
end
