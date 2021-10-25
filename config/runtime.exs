import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  config :thundermoon_web, ThundermoonWeb.Endpoint,
    url: [host: "thundermoon.zero-x.net", port: 80],
    cache_static_manifest: "priv/static/cache_manifest.json",
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    live_view: [signing_salt: System.fetch_env!("SECRET_LIVE_VIEW_KEY")],
    check_origin: ["https://thundermoon.zero-x.net", "//localhost:4000"],
    server: true

  config :thundermoon, Thundermoon.Repo,
    # ssl: true,
    url: System.fetch_env!("DATABASE_URL"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

  config :ueberauth, Ueberauth.Strategy.Github.OAuth,
    client_id: System.get_env("GITHUB_CLIENT_ID"),
    client_secret: System.get_env("GITHUB_CLIENT_SECRET")

  config :sentry,
    dsn: System.get_env("SENTRY_DSN"),
    release: System.get_env("SENTRY_RELEASE")
end
