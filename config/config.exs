# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :weather_bot,
  ecto_repos: [WeatherBot.Repo],
  geocoder: "https://geocode-maps.yandex.ru/1.x/?geocode=%s&format=json",
  weather: "https://api.weather.yandex.ru/v1/informers?lat=%s&lon=%s",
  ya_key: System.get_env("YANDEX_KEY"),
  auth_module: Auth

# Configures the endpoint
config :weather_bot, WeatherBotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8HaS8rFburEFyr8NqW3bvflCuZbjnD7GcLxPPwhoRJdFrgYL2nH4Lmf+zVw1UgmE",
  render_errors: [view: WeatherBotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WeatherBot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :logger,
       backends: [:console, {LoggerFileBackend, :error_log}],
       format: "[$date $time] [$node] $metadata[$level] $message\n"

config :logger, :error_log,
       path: "elixir_dbg.log",
       level: :debug

config :nadia, token: System.get_env("NADIA_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

