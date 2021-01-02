defmodule Sim.RealmTest do
  use ExUnit.Case, async: false

  alias Test.Realm

  require Logger

  setup do
    start_supervised!(
      {Sim.Realm.Supervisor, name: Test.Realm, commands_module: Test.CommandHandler}
    )

    Phoenix.PubSub.subscribe(ThundermoonWeb.PubSub, "Test.Realm")

    on_exit(fn ->
      Phoenix.PubSub.unsubscribe(ThundermoonWeb.PubSub, "Test.Realm")
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

  # describe "set_root" do
  #   test "get new root" do
  #     assert :root == Realm.set_root(:root)
  #     assert :root == Realm.get_root()
  #   end

  #   test "receive broadcast" do
  #     Realm.set_root(:new_root)
  #     assert_receive({:update, data: :new_root})
  #   end
  # end

  describe "create" do
    test "set root" do
      assert :ok = Realm.create(3)
      # as create is executed async root is still nil
      assert nil == Realm.get_root()
    end

    test "receive broadcast" do
      assert :ok = Realm.create(5)
      assert_receive({:update, data: 10})
    end
  end

  describe "simulation loop" do
    setup do
      Realm.create(0)
      assert_receive({:update, data: 0})
      :ok
    end

    test "start" do
      assert :ok = Realm.start_sim()
      assert_receive({:sim, started: true})
    end

    test "stop" do
      assert :ok = Realm.start_sim()
      assert :ok = Realm.stop_sim()
      assert_receive({:sim, started: false})
    end

    test "sim" do
      assert :ok = Realm.start_sim(10)
      # wait one sim cycle
      assert_receive({:update, data: 1})
      Process.sleep(10)
      assert_receive({:update, data: 2})
    end

    test "started?" do
      assert false == Realm.started?()
      Realm.start_sim()
      Process.sleep(1)
      assert true == Realm.started?()
      Realm.stop_sim()
      Process.sleep(1)
      assert false == Realm.started?()
    end
  end

  describe "recover" do
    setup do
      %{root: Realm.create(Factory, %{initial: 0})}
    end

    test "server crash" do
      Realm.start_sim()
      Realm.RealmServer |> GenServer.stop(:shutdown)
      wait_for_all()
      assert 0 >= Realm.get_root()
      assert true == Realm.started?()
    end

    test "simulation loop crash" do
      Realm.start_sim()
      Realm.SimulationLoop |> GenServer.stop(:shutdown)
      assert_receive({:sim, started: false})
      wait_for_all()
      assert 0 >= Realm.get_root()
      assert false == Realm.started?()
    end

    test "data crash" do
      Realm.start_sim()
      Realm.Data |> Agent.stop(:shutdown)
      wait_for_all()
      refute_receive({:sim, started: false})
      assert nil == Realm.get_root()
      assert false == Realm.started?()
    end

    test "sim task crash" do
      # negative number will crash sim
      Realm.set_root(-1)
      Realm.start_sim()
      # wait one sim cycle
      Process.sleep(100)
      assert_receive({:sim, started: false})
      assert -1 == Realm.get_root()
      assert false == Realm.started?()
    end

    test "create crash" do
      assert catch_exit(Realm.create(Factory, :raise))
      wait_for_all()
      assert 0 >= Realm.get_root()
    end
  end

  def wait_for_all() do
    Enum.all?([Realm.RealmServer, Realm.SimulationLoop, Realm.Data], fn process ->
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
