defmodule Handlers.Start do
  @moduledoc false
  use TelegramModule, reg: :process_registry
  use GenServer

  alias Model.TlgmMessage
  alias Helpers.Starter
  alias Helpers.Analitic
  alias Helpers.Message

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_cast(%TlgmMessage{is_cmd: true, msg: msg}, state) do
    %Nadia.Model.Message{
      chat: %{
        id: chId
      },
      from: tUser
    } = msg

    %Nadia.Model.User{
      first_name: fName,
      last_name: lName,
      username: uName
    } = tUser

    strartWeatherHandler(tUser.id)

    Analitic.sendData("add_bot", chId, "add")

    getName(fName, lName, uName)
    |> Message.sendHellow(chId);

    {:noreply, state}
  end

  defp strartWeatherHandler(tId) do
    id = {"weather", tId}
    Starter.startHandler(Handlers.Weather, id)

    Handlers.Msg.changeHandler(
      tId,
      %TlgmMessage{
        module: Handlers.Weather,
        is_cmd: nil,
        action: nil,
        data: nil,
        call_id: id
      }
    )
  end

  defp getName(nil, nil, nil), do: "anonymus"
  defp getName(nil, nil, username), do: "#{username}"
  defp getName(nil, lName, _username), do: "#{lName}"
  defp getName(fName, lName, _username), do: "#{fName} #{lName}"
end
