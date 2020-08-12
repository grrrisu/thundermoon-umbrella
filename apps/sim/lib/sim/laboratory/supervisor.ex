defmodule Sim.Laboratory.Supervisor do
  use Supervisor

  alias Sim.Laboratory.Server

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    children = [
      Sim.Laboratory.Server,
      {DynamicSupervisor, name: Sim.Laboratory.InVitroSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
