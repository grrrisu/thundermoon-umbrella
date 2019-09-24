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
      %{
        id: Thundermoon.GameOfLife,
        start:
          {Sim.RealmSupervisor, :start_link, [Thundermoon.GameOfLife, ThundermoonWeb.Endpoint]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Thundermoon.Supervisor)
  end
end
