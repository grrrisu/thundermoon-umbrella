defmodule Sim.Realm.EventBusTest do
  use ExUnit.Case, async: true

  alias Sim.Realm.EventBus

  setup do
    %{state: %{command_bus: nil}}
  end

  test "handle list of events", %{state: state} do
    events = [{:counter_changed, delta: 2}, {:pawn_added, position: [1, 2]}]
    {:noreply, processed_events, _state} = EventBus.handle_events(events, nil, state)
    assert processed_events == events
  end

  test "handle list of declared events", %{state: state} do
    events = [
      {:event, {:counter_changed, delta: 2}},
      {:event, {:pawn_added, position: [1, 2]}}
    ]

    {:noreply, processed_events, _state} = EventBus.handle_events(events, nil, state)
    assert processed_events == [{:counter_changed, delta: 2}, {:pawn_added, position: [1, 2]}]
  end

  test "handle list of events and commands", %{state: state} do
    events = [
      {:event, {:counter_changed, delta: 2}},
      {:command, {:move_item, id: 1, position: [2, 3]}},
      {:event, {:pawn_added, position: [1, 2]}},
      {:command, {:inc_food, delta: 4}}
    ]

    {:noreply, processed_events, _state} = EventBus.handle_events(events, nil, state)
    assert processed_events == [{:counter_changed, delta: 2}, {:pawn_added, position: [1, 2]}]
  end
end
