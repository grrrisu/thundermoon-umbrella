defmodule Sim.GridTest do
  use ExUnit.Case

  alias Sim.Realm

  setup do
    Sim.Realm.Data.reset()
    GenServer.cast(Realm.SimulationLoop, :stop)
    Phoenix.PubSub.subscribe(ThundermoonWeb.PubSub, "Thundermoon.GameOfLife")

    on_exit(fn ->
      Phoenix.PubSub.unsubscribe(ThundermoonWeb.PubSub, "Thundermoon.GameOfLife")
    end)
  end

  describe "init" do
    test "root" do
      assert nil == Realm.get_root()
    end
  end

  describe "set_root" do
    test "get new root" do
      assert :ok == Realm.set_root(:root)
      assert :root == Realm.get_root()
    end

    test "receive broadcast" do
      Realm.set_root(:new_root)
      assert_receive({:update, data: :new_root})
    end
  end

  describe "create" do
    test "new grid" do
      assert :ok = Realm.create(Thundermoon.GameOfLife.Grid, %{size: 4})
    end

    test "receive broadcast" do
      Realm.create(Thundermoon.GameOfLife.Grid, %{size: 4})
      assert_receive({:update, data: %{0 => %{}}})
    end
  end

  describe "simulation loop" do
    test "start" do
      Realm.start_sim()
      assert_receive({:sim, started: true})
    end

    test "stop" do
      Realm.start_sim()
      Realm.stop_sim()
      assert_receive({:sim, started: false})
    end

    test "started?" do
      Realm.start_sim()
      assert true == Realm.started?()
      Realm.stop_sim()
      assert false == Realm.started?()
    end
  end
end
