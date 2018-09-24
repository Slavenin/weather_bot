defmodule TelegramUpdater do
  @moduledoc false

  use GenServer
  require Logger

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_opts) do
    Process.flag(:trap_exit, true)
    cycle()
    {:ok, %{}}
  end

  def runUpdates do
    send(__MODULE__, {:get_updates, nil})
  end

  defp cycle(), do: cycle(nil)
  defp cycle(id) do
    Process.send_after(self(), {:get_updates, id}, 1000)
  end

  def handle_info({:get_updates, id}, state) do
    try do
      case Nadia.get_updates(offset: id) do
        {:ok, updates} ->

          handleEvents(updates)
        {:error, reason} ->
          IO.inspect(reason)
          cycle(id)
      end
    rescue
      e in Poison.SyntaxError -> Logger.error("Update error: #{inspect(e)}")
    end

    {:noreply, state}
  end

  def handle_info({:EXIT, from_pid, reason}, state) do
    Logger.error(inspect(["process die", from_pid, reason]))
    {:noreply, state}
  end

  defp handleEvents([]), do: cycle()
  defp handleEvents(updates) do
    Enum.map(
      updates,
      fn
        (%Nadia.Model.Update{message: nil, callback_query: msg}) -> msg
        (%Nadia.Model.Update{message: msg, callback_query: nil}) -> msg
        (_msg) -> nil
      end
    )
    |> Enum.filter(fn msg -> msg != nil end)
    |> Enum.each(&sendMsg/1)
    %Nadia.Model.Update{update_id: lastId} = List.last(updates)
    cycle(lastId + 1)
  end

  defp sendMsg(msg) do
    Auth.authAndSend(msg)
  end
end
