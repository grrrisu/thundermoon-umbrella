defmodule Sim.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Sim.Laboratory.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Sim.Laboratory]
    Supervisor.start_link(children, opts)
  end
end
