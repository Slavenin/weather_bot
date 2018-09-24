defmodule Auth do
  @moduledoc false
  @behaviour Behaviours.TelegramAuth

  use GenServer
  alias Helpers.Starter

  @auth_table :auth_users

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def authAndSend(msg) do
    GenServer.cast(__MODULE__, msg)
  end

  def getAuthTable(), do: @auth_table

  def handle_cast(
        %Nadia.Model.Message{
          from: tUser
        } = msg,
        state
      ) do
    handleByUser(tUser, msg)

    {:noreply, state}
  end

  def handle_cast(
        %Nadia.Model.CallbackQuery{
          from: tUser
        } = msg,
        state
      ) do
    handleByUser(tUser, msg)

    {:noreply, state}
  end

  defp handleByUser(
         %Nadia.Model.User{
           id: id
         } = tUser,
         msg
       ) do
    # при старте авторизацию выполняет модуль старта
    case getUser(id) do
      nil -> authUser(tUser)
      _ -> nil
    end

    fId = {"handler", id}
    Starter.startHandler(Handlers.Msg, fId)
    Handlers.Msg.sendInfo(fId, msg)
  end

  def authUser(%Nadia.Model.User{} = tUser) do
    :ets.insert(@auth_table, {tUser.id, tUser})
    tUser
  end

  def getUser(id) do
    case :ets.lookup(@auth_table, id) do
      [{_, user}] -> user
      [] -> nil
    end
  end
end
