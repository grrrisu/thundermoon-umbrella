defmodule Sim.Realm.Supervisor do
  use Supervisor

  alias Sim.Realm

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {opts[:name], opts[:domain_services]},
      name: Realm.server_name(opts[:name], "Supervisor")
    )
  end

  def init({name, domain_services}) do
    children = [
      {Sim.Realm.Data,
       name: Realm.server_name(name, "Data"), pubsub: ThundermoonWeb.PubSub, topic: topic(name)},
      {Sim.Realm.SimulationLoop,
       name: Realm.server_name(name, "SimulationLoop"),
       pubsub: ThundermoonWeb.PubSub,
       topic: topic(name),
       command_bus_module: Realm.server_name(name, "CommandFan")},
      {Sim.Realm.CommandFan,
       services: domain_services,
       task_supervisor_name: Realm.server_name(name, "CommandTaskSupervisor"),
       event_bus_module: Realm.server_name(name, "EventBus"),
       name: Realm.server_name(name, "CommandFan")},
      {Task.Supervisor, name: Realm.server_name(name, "CommandTaskSupervisor")},
      {
        Sim.Realm.EventBus,
        # Kafka, NoSQLDB, RDBMS
        reducers: [Realm.server_name(name, "Broadcaster")],
        name: Realm.server_name(name, "EventBus"),
        task_supervisor_name: Realm.server_name(name, "EventTaskSupervisor")
      },
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp topic(name) do
    name |> Atom.to_string() |> String.replace_leading("Elixir.", "")
  end
end
