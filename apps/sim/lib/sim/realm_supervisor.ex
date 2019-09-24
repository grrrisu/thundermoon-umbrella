defmodule Sim.RealmSupervisor do
  use Supervisor

  def start_link(name, broadcaster) do
    Supervisor.start_link(__MODULE__, {name, broadcaster}, name: name)
  end

  def init({name, broadcaster}) do
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
      {DynamicSupervisor, name: supervisor_module(name), strategy: :one_for_one},
      %{
        id: simulation_loop_module(name),
        start:
          {Sim.SimulationLoop, :start_link,
           [broadcaster, topic(name), simulation_loop_module(name)]}
      }
      # {DynamicSupervisor, name: Thundermoon.DigitSupervisor, strategy: :one_for_one},
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp topic(name) do
    name |> Atom.to_string() |> String.replace_leading("Elixir.", "")
  end

  defp simulation_loop_module(name) do
    Module.concat(name, "SimulationLoop")
  end

  defp realm_module(name) do
    Module.concat(name, "Realm")
  end

  defp supervisor_module(name) do
    Module.concat(name, "RealmSupervisor")
  end
end
