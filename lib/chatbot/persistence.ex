defmodule Chatbot.Persistence do
  use GenServer
  require Logger

  @user "admin"
  @password "admin"
  @base_url "http://localhost:5984"
  @database "chatbot_db"

  def start_link(_) do
    http_client = Application.get_env(:chatbot, :http_client, Http.HttpClientProd)
    GenServer.start_link(__MODULE__, http_client, name: :Persistence)
  end

  @impl true
  def init(http_client) do
      Logger.info("Persistence Initialized")
      do_create_database(http_client)
      {:ok, http_client}
  end

  @impl true
  def handle_call({:store, value = %Chatbot.DbDataScheme{}}, _from, http_client) do
    res = do_create_document(http_client, value)
    {:reply, res, http_client}
  end

  # Creates the database. If it already exists nothing will happen.
  defp do_create_database(http_client) do
    url = "#{@base_url}/#{@database}"
    send_request(http_client, :post, url)
  end

  # Creates a document in the database.
  defp do_create_document(http_client, doc) do
    url = "#{@base_url}/#{@database}"
    do_handle_response(send_request(http_client, :post, url, doc))
  end

  # Function that may handle more requests in the future (:put, :get, ...)
  # Wrapper function to choose appropriate action based on environment
  defp choose_action(http_client, :post, url, body) do
    headers = ["Authorization": "Basic " <> Base.encode64("#{@user}:#{@password}")]
    http_client.post(url, body, headers ++ ["Content-Type": "application/json"])
  end

  # Main function to call based on environment
  defp send_request(http_client, method, url, body \\ nil) do
    choose_action(http_client, method, url, body)
  end

  defp do_handle_response({:ok, %HTTPoison.Response{status_code: 201}}), do: :created
  defp do_handle_response(_), do: :not_created

end
