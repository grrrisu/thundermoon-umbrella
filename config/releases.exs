import Config

config :thundermoon_web, ThundermoonWeb.Endpoint,
  url: [host: "thundermoon.zero-x.net", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  http: [:inet6, port: String.to_integer(System.get_env("PORT", "4000"))],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  server: true

config :thundermoon, Thundermoon.Repo,
  # ssl: true,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

config :bugsnag, api_key: System.get_env("BUGSNAG_API_KEY")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")
