defmodule Behaviours.Telegram do
  @moduledoc """
  Базвое поведение для модуля Telegram
  """

  @callback sendInfo(accountId :: term, info :: term) :: Model.TlgmMessage.t()
end
