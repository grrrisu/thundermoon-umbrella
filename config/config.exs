# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :thundermoon,
  ecto_repos: [Thundermoon.Repo]

config :thundermoon_web,
  ecto_repos: [Thundermoon.Repo],
  generators: [context_app: :thundermoon]

# Configures the endpoint
config :thundermoon_web, ThundermoonWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tppRzffplbnK5cQm15uBQNUPGcM66dQyDYmPmDv+hUPWYmc9DL1ypKuJQr9J2Ect",
  render_errors: [view: ThundermoonWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ThundermoonWeb.PubSub,
  live_view: [signing_salt: "3xuIiywqogg7Ar9EFVpbQGP6lEfmoLzY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, Sentry.LoggerBackend,
  # Send messages like `Logger.error("error")` to Sentry
  capture_log_messages: true,
  # Also send warn messages like `Logger.warn("warning")` to Sentry
  level: :error,
  # Do not exclude exceptions from Plug/Cowboy
  excluded_domains: [],
  # Include metadata added with `Logger.metadata([foo_bar: "value"])`
  metadata: [:foo_bar]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.15.9",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../apps/thundermoon_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [allow_private_emails: true]}
  ]

config :canary,
  repo: Thundermoon.Repo,
  unauthorized_handler: {ThundermoonWeb.AuthorizationHelpers, :handle_unauthorized},
  not_found_handler: {ThundermoonWeb.AuthorizationHelpers, :handle_not_found}

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  included_environments: [:prod],
  environment_name: Mix.env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
