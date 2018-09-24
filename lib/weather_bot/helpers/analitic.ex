defmodule Helpers.Analitic do
  @moduledoc false

  require Logger

  @key System.get_env("ANALITIC_KEY")

  def sendData(msg, userId, intent) do
    try do
      HTTPoison.post(
        "https://chatbase.com/api/message",
        Poison.encode!(
          %{
            "api_key" => @key,
            "type" => "user",
            "platform" => "telegram",
            "message" => msg,
            "intent" => intent,
            "version" => "1.0",
            "user_id" => userId,
            "time_stamp" => :os.system_time(:millisecond)
          }
        ),
        [
          {"Content-Type", "application/json"},
          {"cache-control", "no-cache"}
        ],
        timeout: 1000,
        recv_timeout: 1000
      )
    rescue
      e in _ -> Logger.error("send error: #{inspect(e)}")
    end
  end
end
