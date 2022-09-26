defmodule Sim.Realm.EventBus do
  use GenStage
  require Logger

  alias Sim.Realm.CommandBus

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    Logger.debug("EventBus started")

    {:producer_consumer, %{command_bus: opts[:command_bus]},
     subscribe_to: opts[:domain_services], dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_events(events, _from, state) do
    events =
      events
      |> Enum.map(&process_event(&1, state.command_bus))
      |> Enum.reject(&command_sent(&1))

    {:noreply, events, state}
  end

  defp process_event({:command, command}, command_bus) do
    {:command, CommandBus.dispatch(command_bus, command)}
  end

  defp process_event({:event, event}, _), do: event
  defp process_event(event, _), do: event

  defp command_sent({:command, :ok}), do: true
  defp command_sent(_event), do: false
end
