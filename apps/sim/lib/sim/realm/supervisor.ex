defmodule Sim.Realm.Supervisor do
  use Supervisor

  alias Sim.Realm

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {opts[:name], opts[:commands_module]},
      name: Realm.server_name(opts[:name], "Supervisor")
    )
  end

  def init({name, commands_module}) do
    children = [
      {Sim.Realm.Data,
       name: Realm.server_name(name, "Data"), pubsub: ThundermoonWeb.PubSub, topic: topic(name)},
      {Sim.Realm.SimulationLoop,
       name: Realm.server_name(name, "SimulationLoop"),
       pubsub: ThundermoonWeb.PubSub,
       topic: topic(name),
       command_guard_module: Realm.server_name(name, "CommandGuard")},
      {Sim.Realm.CommandFan,
       services: %{user: UserService, sim: SimService},
       task_supervisor_name: Realm.server_name(name, "CommandTaskSupervisor"),
       name: Realm.server_name(name, "CommandFan")},
      {Sim.Realm.CommandGuard,
       commands_module: commands_module,
       task_supervisor_name: Realm.server_name(name, "CommandTaskSupervisor"),
       name: Realm.server_name(name, "CommandGuard")},
      {Task.Supervisor, name: Realm.server_name(name, "CommandTaskSupervisor")}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp topic(name) do
    name |> Atom.to_string() |> String.replace_leading("Elixir.", "")
  end
end
