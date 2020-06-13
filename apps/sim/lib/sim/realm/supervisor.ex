defmodule Sim.Realm.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts[:name], name: opts[:name] || __MODULE__)
  end

  def init(name) do
    children = [
      {Sim.Realm.Data, name: name, pubsub: ThundermoonWeb.PubSub, topic: topic(name)},
      {Sim.Realm.SimulationLoop, name: name},
      {Sim.Realm.ServerSupervisor, name: name}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  def restart_realm() do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn child -> child |> Tuple.to_list() |> List.first() end)
    |> Enum.map(fn child ->
      :ok = Supervisor.terminate_child(__MODULE__, child)
      child
    end)
    |> Enum.reverse()
    |> Enum.each(fn child ->
      {:ok, _pid} = Supervisor.restart_child(__MODULE__, child)
    end)
  end

  defp topic(name) do
    name |> Atom.to_string() |> String.replace_leading("Elixir.", "")
  end
end
