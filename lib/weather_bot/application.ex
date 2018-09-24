defmodule WeatherBot.Application do
  use Application
  alias Helpers.Tools

  @auth_module Application.get_env(:weather_bot, :auth_module)

  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    #import Supervisor.Spec
    Envy.load([".env"])
    Envy.reload_config

    checkAuthModule()

    children = [
      %{
        id: Registry,
        start: {Registry, :start_link, [:unique, :process_registry]},
        type: :supervisor
      },
      #      %{
      #        id: WeatherBot.Repo,
      #        start: {WeatherBot.Repo, :start_link, []},
      #        type: :supervisor
      #      },
      %{
        id: @auth_module,
        start: {@auth_module, :start_link, []},
        type: :worker
      },
      %{
        id: TelegramUpdater,
        start: {TelegramUpdater, :start_link, []},
        type: :worker
      }
    ]

    :ets.new(Auth.getAuthTable(), [:set, :public, :named_table])

    opts = [strategy: :one_for_one, name: WeatherBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    WeatherBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp checkAuthModule() do
    if(Tools.isBehaviours?(@auth_module, Behaviours.TelegramAuth) === false) do
      raise "Module #{@auth_module} must implement Behaviours.TelegramAuth"
    end
  end

  def getAuthModule(), do: @auth_module
end
