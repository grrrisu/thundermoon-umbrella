defmodule Sim.RealmTest do
  use ExUnit.Case, async: false

  alias Test.Dummy
  alias Test.Dummy.Factory

  require Logger

  setup do
    start_supervised!({Sim.Realm.Supervisor, name: Test.Dummy})
    Phoenix.PubSub.subscribe(ThundermoonWeb.PubSub, "Test.Dummy")

    on_exit(fn ->
      Phoenix.PubSub.unsubscribe(ThundermoonWeb.PubSub, "Test.Dummy")
    end)
  end

  describe "init" do
    test "root" do
      assert nil == Dummy.get_root()
    end

    test "started" do
      assert false == Dummy.started?()
    end
  end

  describe "set_root" do
    test "get new root" do
      assert :root == Dummy.set_root(:root)
      assert :root == Dummy.get_root()
    end

    test "receive broadcast" do
      Dummy.set_root(:new_root)
      assert_receive({:update, data: :new_root})
    end
  end

  describe "create" do
    test "set root" do
      assert 4 = Dummy.create(Factory, %{initial: 4})
      assert 4 == Dummy.get_root()
    end

    test "receive broadcast" do
      Dummy.create(Factory, %{initial: 5})
      assert_receive({:update, data: 5})
    end
  end

  describe "simulation loop" do
    setup do
      %{root: Dummy.create(Factory, %{initial: 0})}
    end

    test "start" do
      assert :ok = Dummy.start_sim()
      assert_receive({:sim, started: true})
    end

    test "stop" do
      assert :ok = Dummy.start_sim()
      # wait one sim cycle
      Process.sleep(100)
      assert :ok = Dummy.stop_sim()
      assert_receive({:sim, started: false})
    end

    test "sim" do
      assert :ok = Dummy.start_sim()
      # wait one sim cycle
      Process.sleep(100)
      assert_receive({:update, data: 1})
    end

    test "started?" do
      assert false == Dummy.started?()
      Dummy.start_sim()
      Process.sleep(1)
      assert true == Dummy.started?()
      Dummy.stop_sim()
      Process.sleep(1)
      assert false == Dummy.started?()
    end
  end

  # @tag :skip
  # describe "recover" do
  #   test "server crash" do
  #     Realm.set_root(:before_server_crash)
  #     Realm.start_sim(fn data -> data end)
  #     Sim.Realm.Server |> GenServer.stop(:shutdown)
  #     wait_for_all()
  #     assert :before_server_crash == Sim.Realm.get_root()
  #     assert true == Sim.Realm.started?()
  #   end

  #   test "simulation loop crash" do
  #     Realm.set_root(:before_loop_crash)
  #     Realm.start_sim(fn data -> data end)
  #     Sim.Realm.SimulationLoop |> GenServer.stop(:shutdown)
  #     assert_receive({:sim, started: false})
  #     wait_for_all()
  #     assert :before_loop_crash == Sim.Realm.get_root()
  #     assert false == Sim.Realm.started?()
  #   end

  #   test "data crash" do
  #     Realm.set_root(:before_data_crash)
  #     Realm.start_sim(fn data -> data end)
  #     Sim.Realm.Data |> Agent.stop(:shutdown)
  #     wait_for_all()
  #     refute_receive({:sim, started: false})
  #     assert nil == Sim.Realm.get_root()
  #     assert false == Sim.Realm.started?()
  #   end

  #   test "sim task crash" do
  #     Realm.set_root(:before_sim_crash)
  #     Realm.start_sim(fn _ -> raise "sim task crashed" end)
  #     assert_receive({:sim, started: false})
  #     wait_for_all()
  #     assert :before_sim_crash == Sim.Realm.get_root()
  #     assert false == Sim.Realm.started?()
  #   end

  #   test "create crash" do
  #     Realm.set_root(:before_create_crash)
  #     assert catch_exit(Realm.create(Sim.Grid, nil))
  #     wait_for_all()
  #     assert :before_create_crash == Sim.Realm.get_root()
  #   end
  # end

  # def wait_for_all() do
  #   Enum.all?([Sim.Realm.Server, Sim.Realm.SimulationLoop, Sim.Realm.Data], fn process ->
  #     wait_for(process)
  #   end)
  # end

  # def wait_for(process) do
  #   Process.sleep(1)

  #   with pid when is_pid(pid) <- Process.whereis(process),
  #        true <- Process.alive?(pid) do
  #     true
  #   else
  #     _any ->
  #       wait_for(process)
  #   end
  # end
end
