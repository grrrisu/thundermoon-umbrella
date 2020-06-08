defmodule Thundermoon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Thundermoon.Repo,
      Thundermoon.ChatMessages,
      Thundermoon.CounterRealmSupervisor,
      Sim.RealmSupervisor.supervise_realm(Thundermoon.GameOfLife, ThundermoonWeb.PubSub)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Thundermoon.Supervisor)
  end
end
