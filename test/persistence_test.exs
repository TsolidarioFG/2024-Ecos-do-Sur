defmodule PersistenceTest do
  use ExUnit.Case
  doctest Chatbot.Persistence

  test "create document error" do
    data = Chatbot.DbDataScheme.new("birth_location", 25, "male", "CA", "Description", "Review")
    assert GenServer.call(:Persistence, {:store, data}) == :not_created
  end

  test "create document" do
    data = Chatbot.DbDataScheme.new("birth_location", 20, "male", "CA", "Description", "Review")
    assert GenServer.call(:Persistence, {:store, data}) == :created
  end

end
