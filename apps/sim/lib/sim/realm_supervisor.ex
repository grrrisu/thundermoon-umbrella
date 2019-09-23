defmodule Sim.RealmSupervisor do
  use Supervisor

  def start_link(name) do
    Supervisor.start_link(__MODULE__, name, name: name)
  end

  def init(name) do
    children = [
      %{
        id: realm_module(name),
        start:
          {Sim.Realm, :start_link,
           [
             [
               name: realm_module(name),
               supervisor_module: supervisor_module(name)
             ]
           ]}
      },
      {DynamicSupervisor, name: supervisor_module(name), strategy: :one_for_one}
      # {DynamicSupervisor, name: Thundermoon.DigitSupervisor, strategy: :one_for_one},
      # {Thundermoon.CounterSimulation, name: Thundermoon.CounterSimulation}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp realm_module(name) do
    Module.concat(name, "Realm")
  end

  defp supervisor_module(name) do
    Module.concat(name, "RealmSupervisor")
  end
end
