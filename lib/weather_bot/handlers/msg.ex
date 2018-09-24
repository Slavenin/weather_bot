defmodule Handlers.Msg do
  @moduledoc """
  Модуль обработки всех входящих сообщений
  """

  use GenServer
  use TelegramModule, reg: :process_registry

  require Logger
  alias Helpers.Starter
  alias Helpers.Message
  alias Helpers.Tools
  alias Model.TlgmMessage

  defmodule State do
    @doc """
    Структура с состоянием процесса
    """
    defstruct lastCall: %TlgmMessage{},
              user: nil,
              tUser: nil,
              tUserId: nil,
              chat: nil,
              msg_buffer: [],
              timer: nil
  end
  @doc """
  Инициализация модуля
  """
  @spec init([{any(), integer()}]) :: {:ok, Handlers.Msg.State.t()}
  def init([{_, accountId}]) do
    {:ok, %State{tUserId: accountId}}
  end

  @doc """
  Апи для изменения текущего обработчика на заданный
  """
  @spec changeHandler(integer(), Model.TlgmMessage.t()) :: :ok
  def changeHandler(accountId, %TlgmMessage{} = to) do
    GenServer.cast(via_tuple({"handler", accountId}), {:change_handler, to})
  end

  @doc """
  Асинхронный обработчик сообщений модуля
  """
  @spec handle_cast(Nadia.Model.Message.t() | Nadia.Model.CallbackQuery.t() | :change_handler, Handlers.Msg.State.t()) :: {:noreply, Handlers.Msg.State.t()}
  def handle_cast(
        %Nadia.Model.Message{text: text} = msg,
        %State{tUserId: accountId, lastCall: tMsg} = state
      ) do
    call = handleMessage(text, msg, accountId, tMsg)
    {:noreply, %State{state | tUser: Auth.getUser(accountId), lastCall: call}}
  end

  def handle_cast(
        %Nadia.Model.CallbackQuery{data: cmd} = msg,
        %State{tUserId: accountId, lastCall: tMsg} = state
      ) do
    call = handleMessage(cmd, msg, accountId, tMsg)
    {:noreply, %State{state | tUser: Auth.getUser(accountId), lastCall: call}}
  end

  def handle_cast(
        {
          :change_handler,
          %TlgmMessage{module: module, is_cmd: isCmd, action: action, data: data, call_id: id}
        },
        %State{lastCall: tMsg} = state
      ) do
    ntMsg = %TlgmMessage{tMsg | module: module, is_cmd: isCmd, action: action, data: data, call_id: id}
    {:noreply, %State{state | lastCall: ntMsg}}
  end

  @doc """
  Обработка входящих сообщений
  """
  @spec handleMessage(nil | binary(), Nadia.Model.Message.t() | Nadia.Model.CallbackQuery.t(), integer(), Model.TlgmMessage.t()) :: Model.TlgmMessage.t()
  def handleMessage(nil, msg, _accountId, tMsg) do
    sendMessage(msg, tMsg)
  end

  def handleMessage(text, msg, accountId, tMsg) do
    if isCommand?(text) do
      analizeCommand(text, msg)
      |> callCommand(accountId)
    else
      sendMessage(msg, tMsg)
    end
  end


  #Проверяет является ли входящее сообщение командой
  @spec isCommand?(binary()) :: boolean
  defp isCommand?(text), do: Regex.match?(~r/^\/.+/, text)

  #Разбирает команду на составляющие
  @spec analizeCommand(binary(), Nadia.Model.Message.t() | Nadia.Model.CallbackQuery.t()) :: {binary(), nil | binary(), nil | binary(), Model.TlgmMessage.t()}
  defp analizeCommand(text, msg) do
    case String.split(text, "|") do
      [cmd] -> {cmd, nil, nil, msg}
      [cmd, action] -> {cmd, action, nil, msg}
      [cmd, action, data] -> {cmd, action, data, msg}
    end
  end

  #Вызывает модуль обработчик для заданной команды
  @spec callCommand({binary(), nil | binary(), nil | binary(), Model.TlgmMessage.t()}, integer()) :: nil |  Model.TlgmMessage.t()
  defp callCommand({"/" <> cmd, action, data, msg}, accountId) do
    sModule = Helpers.Tools.capitalize(cmd)
    module = String.to_existing_atom("Elixir.Handlers.#{sModule}")

    if isTlgmModule?(module) do
      id = {cmd, accountId}
      Starter.startHandler(module, id)

      tMsg = %TlgmMessage{
        call_id: id,
        is_cmd: true,
        module: module,
        action: action,
        data: data,
        msg: msg
      }

      module.sendInfo(id, tMsg)
    else
      Logger.warn("#{module} does not implement Behaviours.Telegram behaviour.")
      nil
    end
  end

  #Проверяет реализацию поведения Telegram
  @spec isTlgmModule?(atom()) :: boolean()
  defp isTlgmModule?(module) do
    Tools.isBehaviours?(module, Behaviours.Telegram)
  end

  #Отправка сообщения заданному модулю
  @spec sendMessage(Nadia.Model.Message.t() | Nadia.Model.CallbackQuery.t(), Model.TlgmMessage.t() | any()) :: Model.TlgmMessage.t() | {:ok, Nadia.Model.Message.t()} | {:error, Nadia.Model.Error.t()}
  defp sendMessage(msg, %TlgmMessage{module: module, call_id: id} = tMsg) do
    ntMsg = %TlgmMessage{tMsg | is_cmd: false, msg: msg}
    module.sendInfo(id, ntMsg)
  end

  defp sendMessage(
         %Nadia.Model.Message{
           chat: %{
             id: chatId
           }
         },
         _tMsg
       ) do
    Message.sendReauth(chatId)
  end
end
