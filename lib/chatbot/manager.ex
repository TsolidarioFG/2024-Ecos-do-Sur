defmodule Chatbot.Manager do
  alias Chatbot.InitialGraph

  @moduledoc """
  This module is the one called by the Worker. It forwards the request to the desired module that is handling the current graph.
  """
  def resolve({_,  [_ | [{state, module} | history]], memory}, user, key, "BACK", message_id), do: resolve({{state, module}, history, memory}, user, key, nil, message_id)
  def resolve({_, [{state, module} | history], memory}, user, key, "CONTINUE", message_id), do: resolve({{state, module}, history, memory}, user, key, nil, message_id)
  def resolve({{state, :initial}, history, memory}, user, key, response, message_id), do: InitialGraph.resolve({state, history, memory}, user, key, response, message_id)
end
