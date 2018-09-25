defmodule TelegramModule do
  @moduledoc false

  defmacro __using__(opts) do
    reg = Keyword.get(opts, :reg)
    quote do
      @behaviour Behaviours.Telegram

      require Logger

      def start_link(accountId) do
        name = via_tuple(accountId)
        GenServer.start_link(__MODULE__, [accountId], name: name)
      end

      defp via_tuple(accountId) do
        {:via, Registry, {unquote(reg), accountId}}
      end

      def sendInfo(accountId, info) do
        Logger.info(inspect([accountId, info]))
        GenServer.cast(via_tuple(accountId), info)
        info
      end
    end
  end
end
