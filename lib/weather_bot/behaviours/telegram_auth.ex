defmodule Behaviours.TelegramAuth do
  @moduledoc """
  Базвое поведение для модуля авторизации Telegram
  """

  @callback authAndSend(msq :: term) :: :ok
  @callback getUser(id :: term) :: term | nil
  @callback getAuthTable() :: atom
end
