defmodule Sim.Realm.CommandFanTest do
  use ExUnit.Case, async: false

  alias Sim.Realm.CommandFan

  setup do
    state = %{
      sim: %{
        module: SimService,
        running_command: nil,
        queue: {[], []}
      },
      movement: %{
        module: MovementService,
        running_command: nil,
        queue: {[], []}
      }
    }

    %{state: state}
  end

  test "init services", %{state: state} do
    services = %{sim: SimService, movement: MovementService}
    initialized_state = CommandFan.init_services(services)
    assert initialized_state == state
  end
end
