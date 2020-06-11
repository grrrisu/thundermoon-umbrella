defmodule Sim.Realm.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    children = [
      {Task.Supervisor, name: Sim.TaskSupervisor},
      Sim.Realm.Data,
      Sim.Realm.SimulationLoop,
      Sim.Realm.Server
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  def restart_realm() do
    Enum.all?([Sim.Realm.Server, Sim.Realm.SimulationLoop, Sim.Realm.Data], fn child ->
      :ok == Supervisor.restart_child(__MODULE__, child)
    end)
  end

  # def supervise_realm(realm_module, pubsub) do
  #   %{
  #     id: realm_module,
  #     start: {Sim.RealmSupervisor, :start_link, [realm_module, pubsub]}
  #   }
  # end

  # def start_link(name, broadcaster) do
  #   Supervisor.start_link(__MODULE__, {name, broadcaster}, name: name)
  # end

  # def init({name, broadcaster}) do
  #   children = [
  #     %{
  #       id: realm_module(name),
  #       start:
  #         {Sim.Realm, :start_link,
  #          [
  #            [
  #              name: realm_module(name),
  #              supervisor_module: supervisor_module(name)
  #            ]
  #          ]}
  #     },
  #     {DynamicSupervisor, name: supervisor_module(name), strategy: :one_for_one},
  #     %{
  #       id: simulation_loop_module(name),
  #       start:
  #         {Sim.SimulationLoop, :start_link,
  #          [broadcaster, topic(name), simulation_loop_module(name)]}
  #     },
  #     {Task.Supervisor, name: Sim.TaskSupervisor}
  #     # {DynamicSupervisor, name: Thundermoon.DigitSupervisor, strategy: :one_for_one},
  #   ]

  #   Supervisor.init(children, strategy: :rest_for_one)
  # end

  # defp topic(name) do
  #   name |> Atom.to_string() |> String.replace_leading("Elixir.", "")
  # end

  # defp simulation_loop_module(name) do
  #   Module.concat(name, "SimulationLoop")
  # end

  # defp realm_module(name) do
  #   Module.concat(name, "Realm")
  # end

  # defp supervisor_module(name) do
  #   Module.concat(name, "RootSupervisor")
  # end
end
