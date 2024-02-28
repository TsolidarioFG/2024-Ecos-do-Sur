defmodule Chatbot.Leader do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    {token, _opts} = Keyword.pop!(opts, :bot_key)
    IO.puts token
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
  def handle_info(:check, %{bot_key: key, last_seen: last_seen, workers_data: workers_data} = state) do
    state =
      key
      |> Telegram.Api.request("getUpdates", offset: last_seen + 1, timeout: 30)
      |> case do
        # No updates from Telegram
        {:ok, []} ->
          state
          # There are updates that need to be handled
        {:ok, updates} ->
          # Process our updates and return the latest update ID and the new workers
          %{last_seen: last_seen, workers_data: updated_workers_data} = handle_updates(updates, last_seen, key, workers_data)
          # Update the last_seen and the workers_data state
          %{state | last_seen: last_seen, workers_data: updated_workers_data}

      end

    # Re-trigger the looping behavior
    next_loop()
    {:noreply, state}
  end

  # Handles updates from Telegram
  defp handle_updates(updates, last_seen, key, workers_data) do
    updates
    # Process our updates
    |> Enum.reduce(
      {last_seen, workers_data},
      fn update, {_, wd} ->
        Logger.info("Update received: #{inspect(update)}")
        wd = handle_update(update, key, wd)
        {update["update_id"], wd}
      end
    )
    # Returns the las update seen
    |> fn {max_update_id, updated_workers_data} ->
      %{last_seen: max_update_id, workers_data: updated_workers_data}
    end.()
  end

  # Handles regular message updates
  defp handle_update(%{"message" => msg, "update_id" => _}, _, workers_data) do
    stored_worker = Enum.find(workers_data, fn %{user_id: user_id} -> "#{user_id}" == "#{msg["chat"]["id"]}" end)
    # If there is already a process handeling the conversation
    if stored_worker != nil do
      GenServer.cast(stored_worker[:pid], {:answer, msg["chat"]["id"] })
      workers_data
    else
      worker_pid = :poolboy.checkout(:worker)
      reply = GenServer.call(worker_pid, {:answer, msg["chat"]["id"] })
      updated_workers_data = [%{pid: worker_pid, user_id: reply} | workers_data]
      updated_workers_data
    end
  end


  # Schedules the next check for updates after a certain delay
  defp next_loop do
    Process.send_after(self(), :check, 0)
  end


end
