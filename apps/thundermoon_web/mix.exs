defmodule ThundermoonWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :thundermoon_web,
      version: "0.7.0",
      build_path: "../../_build",
      # config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ThundermoonWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :ueberauth]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env) when env in [:test, :integration], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.2.0"},
      {:phoenix_live_view, "~> 0.17.0"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:thundermoon, in_umbrella: true},
      {:sim, in_umbrella: true},
      {:game_of_life, in_umbrella: true},
      {:jason, "~> 1.2"},
      {:poison, "~> 5.0.0"},
      {:plug_cowboy, "~> 2.5"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_github, "~> 0.8.0"},
      {:canada, "~> 1.0.1"},
      {:canary, "~> 1.1.1"},
      {:sentry, "~> 8.0"},
      {:hackney, "~> 1.8"},
      {:observer_cli, "~> 1.5"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:floki, "~> 0.30", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, we extend the test task to create and migrate the database.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
