defmodule Chatbot.PersonGraph do
  alias Chatbot.CommonFunctions
  import ChatBot.Gettext

  @doc """
  This module represents the Person Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # SOLUTIONS
  ##################################
  # S1 -----
  def resolve({:S1, _, _}, user, key, _, message_id), do:  CommonFunctions.do_finalize_simple(gettext("PERSON_S1"), user, message_id, key)
end
