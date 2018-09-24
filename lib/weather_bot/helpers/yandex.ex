defmodule Helpers.Yandex do
  @moduledoc false

  require Logger
  alias Helpers.Message

  @geocoder Application.get_env(:weather_bot, :geocoder)
  @weather Application.get_env(:weather_bot, :weather)

  def getWeather({lat, lot}, _chatId) do
    getWeatherFromAPI("#{lat} #{lot}")
  end

  def getWeather(addr, chatId) do
    case getLatLot(addr) do
      {
        :ok,
        %{
          "response" => %{
            "GeoObjectCollection" => data
          }
        }
      } -> handleData(data, chatId)
      {:error, _} ->
        Message.sendError(chatId)
        {:ok, false}
    end
  end

  defp handleData(
         %{
           "metaDataProperty" => %{
             "found" => "0"
           }
         },
         chatId
       ) do
    Message.sendNotFound(chatId)
    {:ok, false}
  end

  defp handleData(
         %{
           "featureMember" => results
         },
         _chatId
       ) do
    %{
      "GeoObject" => %{
        "Point" => %{
          "pos" => pos
        }
      }
    } = results
        |> hd

    getWeatherFromAPI(pos)
  end

  defp getLatLot(addr) do
    ExPrintf.sprintf(@geocoder, [addr])
    |> request
  end

  defp getWeatherFromAPI(pos) do
    [lot, lat] = String.split(pos)
    ExPrintf.sprintf(@weather, [lat, lot])
    |> request(["X-Yandex-API-Key": "#{getYaKey()}"])
  end

  defp request(url, headers \\ []) do
    try do
      case HTTPoison.get(url, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          {:ok, Poison.decode!(body)}
        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
        other ->
          Logger.error(inspect(other))
          {:error, other}
      end
    rescue
      e in _ ->
        Logger.error(inspect(e))
        {:error, e}
    end
  end

  defp getYaKey do
    Application.get_env(:weather_bot, :ya_key)
  end

end
