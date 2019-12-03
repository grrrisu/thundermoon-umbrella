import Config

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :appsignal, :config, push_api_key: System.get_env("APPSIGNAL_PUSH_API_KEY")
