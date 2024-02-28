defmodule Chatbot.Leader do
  use GenServer
  require Logger

  @moduledoc """
  Chatbot.Leader is responsible for managing all the workers of the app.

  It can ask for a new worker to be activated or use already activated ones.

  It's the one who distributes the messages that the app receives.
  """

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
      |> handle_get_updates(state)
    # Re-trigger the looping behavior
    next_loop()
    {:noreply, state}
  end

  defp handle_get_updates({:ok, []}, state) do
    state
  end

  defp handle_get_updates({:ok, updates}, state) do
    %{last_seen: last_seen, workers_data: updated_workers_data} = handle_multiple_updates(updates, state.last_seen, state.bot_key, state.workers_data)
    # Update the last_seen and the workers_data state
    %{state | last_seen: last_seen, workers_data: updated_workers_data}
  end

  # Handles updates from Telegram
  defp handle_multiple_updates(updates, last_seen, key, workers_data) do
    {max_update_id, updated_workers_data} = updates
    # Process our updates
    |> Enum.reduce(
      {last_seen, workers_data},
      fn update, {_, wd} ->
        Logger.info("Update received: #{inspect(update)}")
        wd = handle_one_update(update, key, wd)
        {update["update_id"], wd}
      end
    )
    # Returns the last update seen and the updated workers list
    %{last_seen: max_update_id, workers_data: updated_workers_data}
  end

  # Handles regular message updates
  defp handle_one_update(%{"message" => msg, "update_id" => _}, _, workers_data) do
    stored_worker = Enum.find(workers_data, fn %{user_id: user_id} -> user_id == msg["chat"]["id"] end)
    # If there is already a process handling the conversation
    if stored_worker != nil do
      GenServer.cast(stored_worker[:pid], :answer)
      workers_data
    else
      worker_pid = :poolboy.checkout(:worker)
      reply = GenServer.call(worker_pid, {:answer, msg["chat"]["id"] })
      [%{pid: worker_pid, user_id: reply} | workers_data]
    end
  end

  # Schedules the next check for updates after a certain delay
  defp next_loop do
    Process.send_after(self(), :check, 0)
  end
end
