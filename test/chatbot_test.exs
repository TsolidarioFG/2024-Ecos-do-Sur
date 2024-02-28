defmodule ChatbotTest do
  use ExUnit.Case
  doctest Chatbot

  test "greets the world" do
    assert Chatbot.hello() == :world
  end
end
