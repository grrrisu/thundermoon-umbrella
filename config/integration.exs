import Config

import_config "dev.exs"

config :thundermoon_web, ThundermoonWeb.Endpoint, code_reloader: false

config :thundermoon, Thundermoon.Repo,
  database: "thundermoon_integration",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

if System.get_env("DB_USER") do
  config :thundermoon, Thundermoon.Repo,
    username: System.get_env("DB_USER"),
    password: System.get_env("DB_PASSWORD")
end
