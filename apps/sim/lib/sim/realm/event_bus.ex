defmodule Sim.Realm.EventBus do
  use GenStage
  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts[:domain_services], name: opts[:name] || __MODULE__)
  end

  def init(domain_services) do
    Logger.debug("EventBus started")

    {:producer_consumer, nil,
     subscribe_to: domain_services, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end
