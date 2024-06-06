defmodule Chatbot.Manager do
  alias Chatbot.FaqWork
  alias Chatbot.FaqCommerce
  alias Chatbot.PersonGraph
  alias Chatbot.FaqGraph
  alias Chatbot.FaqHealthcareGraph
  alias Chatbot.FaqCaResources
  alias Chatbot.PersonWorkGraph
  alias Chatbot.PersonSchoolGraph
  alias Chatbot.HomeGraph
  alias Chatbot.CommerceGraph
  alias Chatbot.LeisureGraph
  alias Chatbot.SchoolGraph
  alias Chatbot.HospitalGraph
  alias Chatbot.TransportGraph
  alias Chatbot.WorkGraph
  alias Chatbot.InitialGraph

  @moduledoc """
  This module is the one called by the Worker. It forwards the request to the desired module that is handling the current graph.
  """
  def resolve({_,  [{:start, _ } | [_ | [ _ | [_ | history]]]], memory}, user, key, "BACK", message_id), do: resolve({{:U2, :initial}, history, memory}, user, key, nil, message_id)
  def resolve({_,  [_ | [{state, module} | history]], memory}, user, key, "BACK", message_id), do: resolve({{state, module}, history, memory}, user, key, nil, message_id)
  def resolve({_, [{state, module} | history], memory}, user, key, "CONTINUE", message_id), do: resolve({{state, module}, history, memory}, user, key, nil, message_id)
  def resolve({_, _, _}, _, _, "EXIT", _), do: {:solved, nil, nil}
  def resolve({{state, :initial}, history, memory}, user, key, response, message_id), do: InitialGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :leisure}, history, memory}, user, key, response, message_id), do: LeisureGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :school}, history, memory}, user, key, response, message_id), do: SchoolGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :hospital}, history, memory}, user, key, response, message_id), do: HospitalGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :transport}, history, memory}, user, key, response, message_id), do: TransportGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :commerce}, history, memory}, user, key, response, message_id), do: CommerceGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :work}, history, memory}, user, key, response, message_id), do: WorkGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :home}, history, memory}, user, key, response, message_id), do: HomeGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :school_per}, history, memory}, user, key, response, message_id), do: PersonSchoolGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :work_per}, history, memory}, user, key, response, message_id), do: PersonWorkGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :faq}, history, memory}, user, key, response, message_id), do: FaqGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :faq_healthcare}, history, memory}, user, key, response, message_id), do: FaqHealthcareGraph.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :faq_ca_resources}, history, memory}, user, key, response, message_id), do: FaqCaResources.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :faq_commerce}, history, memory}, user, key, response, message_id), do: FaqCommerce.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :faq_work}, history, memory}, user, key, response, message_id), do: FaqWork.resolve({state, history, memory}, user, key, response, message_id)
  def resolve({{state, :person}, history, memory}, user, key, response, message_id), do: PersonGraph.resolve({state, history, memory}, user, key, response, message_id)

end
