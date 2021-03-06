defmodule Sim.Realm.Supervisor do
  use Supervisor

  alias Sim.Realm

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, {opts[:name], opts[:domain_services], opts[:pub_sub]},
      name: Realm.server_name(opts[:name], "Supervisor")
    )
  end

  def init({name, domain_services, pub_sub}) do
    children = [
      {Sim.Realm.Data, name: Realm.server_name(name, "Data")},
      {Sim.Realm.SimulationLoop,
       name: Realm.server_name(name, "SimulationLoop"),
       command_bus_module: Realm.server_name(name, "CommandBus")},
      {Sim.Realm.CommandBus,
       services: domain_services,
       task_supervisor_module: Realm.server_name(name, "CommandTaskSupervisor"),
       event_bus_module: Realm.server_name(name, "EventBus"),
       name: Realm.server_name(name, "CommandBus")},
      {Task.Supervisor, name: Realm.server_name(name, "CommandTaskSupervisor")},
      {
        Sim.Realm.EventBus,
        # Kafka, NoSQLDB, RDBMS
        reducers: %{Sim.Realm.Broadcaster => Realm.server_name(name, "Broadcaster")},
        name: Realm.server_name(name, "EventBus"),
        task_supervisor_name: Realm.server_name(name, "EventTaskSupervisor")
      },
      {Sim.Realm.Broadcaster,
       name: Realm.server_name(name, "Broadcaster"), pub_sub: pub_sub, topic: topic(name)},
      {Task.Supervisor, name: Realm.server_name(name, "EventTaskSupervisor")}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp topic(name) do
    name |> Atom.to_string() |> String.replace_leading("Elixir.", "")
  end
end
