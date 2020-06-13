defmodule Sim.RealmTest do
  use ExUnit.Case, async: false

  alias Sim.Realm

  require Logger

  setup do
    Sim.Realm.Supervisor.restart_realm()
    wait_for_all()
    Phoenix.PubSub.subscribe(ThundermoonWeb.PubSub, "Thundermoon.GameOfLife")

    on_exit(fn ->
      Phoenix.PubSub.unsubscribe(ThundermoonWeb.PubSub, "Thundermoon.GameOfLife")
    end)
  end

  describe "init" do
    test "root" do
      assert nil == Realm.get_root()
    end

    test "started" do
      assert false == Realm.started?()
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
      Realm.start_sim(fn data -> data end)
      assert_receive({:sim, started: true})
    end

    test "stop" do
      Realm.start_sim(fn data -> data end)
      Realm.stop_sim()
      assert_receive({:sim, started: false})
    end

    test "started?" do
      assert false == Realm.started?()
      Realm.start_sim(fn data -> data end)
      assert true == Realm.started?()
      Realm.stop_sim()
      assert false == Realm.started?()
    end
  end

  describe "recover" do
    test "server crash" do
      Realm.set_root(:before_server_crash)
      Realm.start_sim(fn data -> data end)
      Sim.Realm.Server |> GenServer.stop(:shutdown)
      wait_for_all()
      assert :before_server_crash == Sim.Realm.get_root()
      assert true == Sim.Realm.started?()
    end

    test "simulation loop crash" do
      Realm.set_root(:before_loop_crash)
      Realm.start_sim(fn data -> data end)
      Sim.Realm.SimulationLoop |> GenServer.stop(:shutdown)
      assert_receive({:sim, started: false})
      wait_for_all()
      assert :before_loop_crash == Sim.Realm.get_root()
      assert false == Sim.Realm.started?()
    end

    test "data crash" do
      Realm.set_root(:before_data_crash)
      Realm.start_sim(fn data -> data end)
      Sim.Realm.Data |> Agent.stop(:shutdown)
      wait_for_all()
      refute_receive({:sim, started: false})
      assert nil == Sim.Realm.get_root()
      assert false == Sim.Realm.started?()
    end

    test "sim task crash" do
      Realm.set_root(:before_sim_crash)
      Realm.start_sim(fn _ -> raise "sim task crashed" end)
      assert_receive({:sim, started: false})
      wait_for_all()
      assert :before_sim_crash == Sim.Realm.get_root()
      assert false == Sim.Realm.started?()
    end

    test "create crash" do
      Realm.set_root(:before_create_crash)
      assert catch_exit(Realm.create(Sim.Grid, nil))
      wait_for_all()
      assert :before_create_crash == Sim.Realm.get_root()
    end
  end

  def wait_for_all() do
    Enum.all?([Sim.Realm.Server, Sim.Realm.SimulationLoop, Sim.Realm.Data], fn process ->
      wait_for(process)
    end)
  end

  def wait_for(process) do
    Process.sleep(1)

    with pid when is_pid(pid) <- Process.whereis(process),
         true <- Process.alive?(pid) do
      true
    else
      _any ->
        wait_for(process)
    end
  end
end
