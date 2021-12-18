defmodule Sim.Realm.ReducerSupervisor do
  use Supervisor

  alias Sim.Realm.EventReducer

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(opts) do
    children =
      Enum.map(
        opts[:reducers],
        &Supervisor.child_spec({EventReducer, [reducer: &1, event_bus: opts[:event_bus]]}, id: &1)
      )

    Supervisor.init(children, strategy: :one_for_one)
  end
end
