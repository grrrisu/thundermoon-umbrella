defmodule Sim.Realm.ServerSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts[:name],
      name: (opts[:name] && server_supervisor_name(opts[:name])) || __MODULE__
    )
  end

  def init(name) do
    children = [
      {Sim.Realm.Server.server_name(name), name: name},
      {Task.Supervisor, name: task_supervisor_name(name)}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp server_supervisor_name(name) do
    Module.concat(name, "ServerSupervisor")
  end

  defp task_supervisor_name(name) do
    Module.concat(name, "TaskSupervisor")
  end
end
