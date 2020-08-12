defmodule Sim.Laboratory.InVitroTest do
  use ExUnit.Case

  alias Sim.Laboratory.InVitro

  setup do
    %{pid: start_supervised!(InVitro)}
  end

  describe "create" do
    test "an object", %{pid: pid} do
      assert {:ok, %{}} = GenServer.call(pid, {:create, fn -> Map.new() end})
    end
  end

  describe "sim" do
    test "counter", %{pid: pid} do
      assert {:ok, 0} = GenServer.call(pid, {:create, fn -> 0 end})
      assert :ok = GenServer.call(pid, {:start, fn n -> n + 1 end})
      send(pid, :tick)
      assert 0 < GenServer.call(pid, :object)
      assert :ok = GenServer.call(pid, :stop)
    end
  end
end
