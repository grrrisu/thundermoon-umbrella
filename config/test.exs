use Mix.Config

# Configure your database
config :thundermoon, Thundermoon.Repo,
  database: "thundermoon_test",
  hostname: System.get_env("DB_HOST", "localhost"),
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

if System.get_env("DB_USER") do
  config :thundermoon, Thundermoon.Repo,
    username: System.get_env("DB_USER"),
    password: System.get_env("DB_PASSWORD")
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :thundermoon_web, ThundermoonWeb.Endpoint,
  http: [port: 4002],
  url: [host: System.get_env("APP_HOST", "localhost")],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

config :hound,
  driver: "phantomjs",
  host: "http://#{System.get_env("BROWSER_HOST", "localhost")}",
  port: 8910,
  app_port: 4002,
  app_host: "http://#{System.get_env("APP_HOST", "localhost")}"
