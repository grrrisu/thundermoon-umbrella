defmodule Sim.Realm.SimulationLoopTest do
  use ExUnit.Case, async: true

  alias Sim.Realm.SimulationLoop

  setup do
    pid = start_supervised!({SimulationLoop, name: :test_simulation_loop})
    %{pid: pid}
  end

  test "start and stop simulation", %{pid: pid} do
    refute SimulationLoop.running?(pid)
    SimulationLoop.start(pid, 10_000, fn -> :ok end)
    Process.sleep(1)
    assert SimulationLoop.running?(pid)
    SimulationLoop.stop(pid)
    refute SimulationLoop.running?(pid)
  end

  test "tick stops simulation", %{pid: pid} do
    refute SimulationLoop.running?(pid)
    SimulationLoop.start(pid, 10_000, fn -> :stop end)
    Process.sleep(1)
    refute SimulationLoop.running?(pid)
  end
end
