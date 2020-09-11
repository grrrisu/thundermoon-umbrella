defmodule Sim.Laboratory.InVitroTest do
  use ExUnit.Case

  alias Phoenix.PubSub

  alias Sim.Laboratory.InVitro

  setup do
    PubSub.subscribe(ThundermoonWeb.PubSub, "1")
    %{pid: start_supervised!({InVitro, entry_id: "1", pub_sub: ThundermoonWeb.PubSub})}
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

    test "receive changes", %{pid: pid} do
      assert {:ok, 0} = GenServer.call(pid, {:create, fn -> 0 end})
      assert :ok = GenServer.call(pid, {:start, fn _n -> 1 end})
      assert_receive {:sim, [started: true]}
      send(pid, :tick)
      assert_receive {:update, [data: 1]}
      assert :ok = GenServer.call(pid, :stop)
      assert_receive {:sim, [started: false]}
    end
  end
end
