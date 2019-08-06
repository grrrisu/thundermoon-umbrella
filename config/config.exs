# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

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
  render_errors: [view: ThundermoonWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ThundermoonWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [allow_private_emails: true]}
  ]

config :canary,
  repo: Thundermoon.Repo,
  unauthorized_handler: {ThundermoonWeb.AuthorizationHelpers, :handle_unauthorized},
  not_found_handler: {ThundermoonWeb.AuthorizationHelpers, :handle_not_found}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
