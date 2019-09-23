defmodule Sim.RealmSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, name, name: name)
  end

  def init(name) do
    children = [
      %{
        id: Module.concat(name, "Realm"),
        start:
          {Sim.Realm, :start_link,
           [
             [
               name: Module.concat(name, "Realm"),
               supervisor_module: Module.concat(name, "RealmSupervisor"),
               root_module: Module.concat(name, "Root")
             ]
           ]}
      }
      # {DynamicSupervisor, name: supervisor_module, strategy: :one_for_one}
      # {DynamicSupervisor, name: Thundermoon.DigitSupervisor, strategy: :one_for_one},
      # {Thundermoon.CounterSimulation, name: Thundermoon.CounterSimulation}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  # def child_spec(module) do
  #   Supervisor.child_spec(module)
  # end
end
