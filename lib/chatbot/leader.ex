defmodule Chatbot.Leader do
  use GenServer
  require Logger
  alias Chatbot.TelegramWrapper, as: TelegramWrapper

  @moduledoc """
  Chatbot.Leader is responsible for managing all the workers of the app.

  It can ask for a new worker to be activated or use already activated ones.

  It's the one who distributes the messages that the app receives.
  """

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    GenServer.start(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    {token, _opts} = Keyword.pop!(opts, :bot_key)
    case Telegram.Api.request(token, "getMe") do
      # Success
      {:ok, me} ->
        Logger.info("Bot successfully self-identified: #{me["username"]}")
        state = %{
          bot_key: token,
          me: me,
          last_seen: -2,
          workers_data: []
        }
        next_loop()
        {:ok, state}
      # Failure
      {:error, reason} ->
        Logger.error("Failed to initialize bot: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  # Handles the :check message
  @impl GenServer
  def handle_info(:check, %{bot_key: key, last_seen: last_seen, workers_data: _} = state) do
    state =
      key
      |> Telegram.Api.request("getUpdates", offset: last_seen + 1, timeout: 30)
      |> do_handle_get_updates(state)
    # Re-trigger the looping behavior
    next_loop()
    {:noreply, state}
  end

  # When a worker dies, the leader must be notified to delete it from workers_data. No message to the user.
  @impl GenServer
  def handle_cast({:worker_dead, pid, _user_id, nil}, state) do
    worker = Enum.find(state.workers_data, fn %{pid: worker} -> worker == pid end)
    do_handle_worker_dead(worker, state)
  end

  # When a worker dies, the leader must be notified to delete it from workers_data. Message to the user.
  @impl GenServer
  def handle_cast({:worker_dead, pid, user_id, message}, state) do
    worker = Enum.find(state.workers_data, fn %{pid: worker} -> worker == pid end)
    TelegramWrapper.send_message(state.bot_key, user_id, message)
    do_handle_worker_dead(worker, state)
  end

  defp do_handle_worker_dead(nil, state), do: {:noreply, state}

  defp do_handle_worker_dead(worker, state) do
    new_workers_data = Enum.reject(state.workers_data, fn %{pid: worker_pid, user_id: _} -> worker_pid == worker.pid end)
    {:noreply, %{state | workers_data: new_workers_data}}

  end

  # There are no new updates to be processed
  defp do_handle_get_updates({:ok, []}, state) do
    state
  end

  # There are updates to handle
  defp do_handle_get_updates({:ok, updates}, state) do
    %{last_seen: last_seen, workers_data: updated_workers_data} = do_handle_multiple_updates(updates, state.last_seen, state.bot_key, state.workers_data)
    # Update the last_seen and the workers_data state
    %{state | last_seen: last_seen, workers_data: updated_workers_data}
  end

  # Handles updates from Telegram
  defp do_handle_multiple_updates(updates, last_seen, key, workers_data) do
    {max_update_id, updated_workers_data} = updates
    # Process our updates
    |> Enum.reduce(
      {last_seen, workers_data},
      fn update, {_, wd} ->
        Logger.info("Update received: #{inspect(update)}")
        wd = do_handle_one_update(update, key, wd)
        {update["update_id"], wd}
      end
    )
    # Returns the last update seen and the updated workers list
    %{last_seen: max_update_id, workers_data: updated_workers_data}
  end

  # Handles regular message updates
  defp do_handle_one_update(%{"message" => msg, "update_id" => _} = update, key, workers_data) do
    stored_worker = Enum.find(workers_data, fn %{user_id: user_id} -> user_id == msg["chat"]["id"] end)
    # If there is already a process handling the conversation
    if stored_worker != nil do
      GenServer.cast(stored_worker[:pid], {:answer, update})
      workers_data
    else
      worker_pid = :poolboy.checkout(:worker)
      reply = GenServer.call(worker_pid, {:answer, key, msg["chat"]["id"] })
      [%{pid: worker_pid, user_id: reply} | workers_data]
    end
  end

  # Handles an update that contains a callback query when workers_data is empty
  defp do_handle_one_update(%{"callback_query" => query, "update_id" => _}, key, [] = workers_data)  do
    worker_pid = :poolboy.checkout(:worker)
    case GenServer.call(worker_pid, {:answer, key, query["from"]["id"], query }) do
      :worker_dead ->
        workers_data
      user_id ->
        [%{pid: worker_pid, user_id: user_id} | workers_data]
    end
  end

  # Handles an update that contains a callback query when workers_data is not empty
  defp do_handle_one_update(%{"callback_query" => query, "update_id" => _} = update, key, workers_data) do
    stored_worker = Enum.find(workers_data, fn %{user_id: user_id} -> user_id == query["from"]["id"] end)
    # If there is already a process handling the conversation
    if stored_worker != nil do
      GenServer.cast(stored_worker[:pid], {:answer, update})
      workers_data
    else
      worker_pid = :poolboy.checkout(:worker)
      case GenServer.call(worker_pid, {:answer, key, query["from"]["id"], query }) do
        :worker_dead ->
          workers_data
        user_id ->
          [%{pid: worker_pid, user_id: user_id} | workers_data]
      end
    end
  end



  # Schedules the next check for updates after a certain delay
  defp next_loop do
    Process.send_after(self(), :check, 1000)
  end
end
