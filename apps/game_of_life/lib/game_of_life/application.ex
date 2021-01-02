defmodule GameOfLife.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Sim.Realm.Supervisor, name: GameOfLife, commands_module: GameOfLife.Commands}
    ]

    opts = [
      strategy: :one_for_one,
      name: GameOfLife
    ]

    Supervisor.start_link(children, opts)
  end
end
