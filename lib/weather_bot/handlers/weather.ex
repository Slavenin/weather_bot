defmodule Handlers.Weather do
  @moduledoc false
  use GenServer
  use TelegramModule, reg: :process_registry

  alias Model.TlgmMessage
  alias Helpers.Message
  alias Helpers.Yandex
  alias Helpers.Analitic

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_cast(
        %TlgmMessage{
          is_cmd: false,
          action: nil,
          data: nil,
          msg: %Nadia.Model.Message{
            chat: %{
              id: chatId
            },
            location: %Nadia.Model.Location{
              latitude: lat,
              longitude: lot
            }
          }
        },
        state
      ) do

    getWeather({lot, lat}, chatId)
    Analitic.sendData("get", chatId, "weather")

    {:noreply, state}
  end

  def handle_cast(
        %TlgmMessage{
          is_cmd: false,
          msg: %Nadia.Model.Message{
            text: addr,
            chat: %{
              id: chatId
            }
          }
        },
        state
      ) do

    getWeather(addr, chatId)

    {:noreply, state}
  end

  defp getWeather(addr, chatId) do
    case Yandex.getWeather(addr, chatId) do
      {:ok, false} -> nil
      {:ok, weather} ->
        Analitic.sendData("get", chatId, "weather")
        Message.showWeather(weather, chatId)
      _ -> nil
    end
  end
end
