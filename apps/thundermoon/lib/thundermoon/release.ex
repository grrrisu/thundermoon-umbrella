defmodule Thundermoon.Release do
  @app :thundermoon

  alias Ecto.Migrator

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Migrator.with_repo(repo, &Migrator.run(&1, :down, to: version))
  end

  def seeds do
    IO.puts("todo!")
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
