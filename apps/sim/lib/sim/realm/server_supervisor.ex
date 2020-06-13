defmodule Sim.Realm.ServerSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    children = [
      Sim.Realm.Server,
      {Task.Supervisor, name: Sim.TaskSupervisor}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
