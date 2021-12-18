defmodule Sim.Realm.EventReducer do
  use GenStage
  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: opts[:reducer])
  end

  def init(opts) do
    Logger.info("#{opts[:reducer]} started")
    {:consumer, %{reducer: opts[:reducer]}, subscribe_to: [opts[:event_bus]]}
  end

  def handle_events(events, _from, state) do
    state.reducer.reduce(events)
    {:noreply, [], state}
  end
end
