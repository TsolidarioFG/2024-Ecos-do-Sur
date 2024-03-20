defmodule Chatbot.Persistence do
  use GenServer
  require Logger

  @user "admin"
  @password "admin"
  @base_url "http://localhost:5984"
  @database "chatbot_db"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :Persistence)
  end

  @impl true
  def init(_) do
      Logger.info("Persistence Initialized")
      do_create_database()
      {:ok, nil}
  end

  @impl true
  def handle_call({:store, value = %Chatbot.DbDataScheme{}}, _from, state) do
    res = do_create_document(value)
    {:reply, res, state}
  end

  # Creates the database. If it already exists nothing will happen.
  defp do_create_database() do
    url = "#{@base_url}/#{@database}"
    send_request(:post, url)
  end

  # Creates a document in the database.
  defp do_create_document(doc) do
    url = "#{@base_url}/#{@database}"
    do_handle_response(send_request(:post, url, doc))
  end

  # Function that may handle more requests in the future (:put, :get, ...)
  defp send_request(method, url, body \\ nil) do
    headers = ["Authorization": "Basic " <> Base.encode64("#{@user}:#{@password}")]
    case method do
      :post -> HTTPoison.post(url, Poison.encode!(body), headers ++ ["Content-Type": "application/json"])
    end
  end

  defp do_handle_response({:ok, %HTTPoison.Response{status_code: 201}}), do: :created
  defp do_handle_response(_), do: :not_created

end
