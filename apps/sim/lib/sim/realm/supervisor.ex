defmodule Sim.Realm.Supervisor do
  use Supervisor

  def start_link(config) do
    children = [
      {Sim.Realm.Data, name: child_name(config, Data)},
      {Sim.Realm.CommandBus,
       [
         name: child_name(config, CommandBus),
         partitions: Keyword.keys(config[:domain_services])
       ]},
      {Sim.Realm.ServiceSupervisor,
       [
         name: child_name(config, ServiceSupervisor),
         domain_services: config[:domain_services],
         command_bus: child_name(config, CommandBus)
       ]},
      {Sim.Realm.EventBus,
       [
         name: child_name(config, EventBus),
         domain_services: Keyword.values(config[:domain_services])
       ]},
      {Sim.Realm.ReducerSupervisor,
       [
         name: child_name(config, ReducerSupervisor),
         reducers: config[:reducers],
         event_bus: child_name(config, EventBus)
       ]},
      {Sim.Realm.SimulationLoop,
       name: child_name(config, SimulationLoop),
       command_bus_module: child_name(config, CommandBus)}
    ]

    opts = [strategy: :rest_for_one, name: child_name(config, Supervisor)]
    IO.inspect(children)
    Supervisor.start_link(children, opts)
  end

  defp child_name(config, module) do
    prefix = if Keyword.has_key?(config, :name), do: config[:name], else: Sim.Realm
    Module.concat(prefix, module)
  end
end
