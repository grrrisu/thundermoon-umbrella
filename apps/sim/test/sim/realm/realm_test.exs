defmodule Sim.RealmTest do
  use ExUnit.Case, async: false

  alias Test.Realm

  require Logger

  setup do
    start_supervised!({Phoenix.PubSub, name: :test_pub_sub})

    start_supervised!(
      {Sim.Realm.Supervisor,
       name: Test.Realm, domain_services: %{test: Test.CommandHandler}, pub_sub: :test_pub_sub}
    )

    Phoenix.PubSub.subscribe(:test_pub_sub, "Test.Realm")
  end

  describe "init" do
    test "root" do
      assert nil == Realm.get_root()
    end

    test "started" do
      assert false == Realm.started?()
    end
  end

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
      assert :ok = Realm.start_sim(1_000, {:test, :sim})
      assert_receive({:sim, started: true})
    end

    test "stop" do
      assert :ok = Realm.start_sim(1_000, {:test, :sim})
      assert :ok = Realm.stop_sim()
      assert_receive({:sim, started: false})
    end

    test "sim" do
      assert :ok = Realm.start_sim(10)
      assert_receive({:update, data: 1})
      # wait one sim cycle
      Process.sleep(10)
      assert_receive({:update, data: 2})
    end

    test "started?" do
      assert false == Realm.started?()
      Realm.start_sim(1_000, {:test, :sim})
      Process.sleep(1)
      assert true == Realm.started?()
      Realm.stop_sim()
      Process.sleep(1)
      assert false == Realm.started?()
    end
  end

  describe "recover" do
    setup do
      start_supervised!(TestRecoverSupervisor)
      Process.sleep(1000)
      Realm.create(0)
      assert_receive({:update, data: 0})
      :ok
    end

    @tag :skip
    test "server crash" do
      Realm.start_sim(1_000, {:test, :sim})
      Test.Realm.CommandGuard |> GenServer.stop(:shutdown)
      wait_for_all()
      assert 0 <= Realm.get_root()
      assert true == Realm.started?()
    end

    @tag :skip
    test "simulation loop crash" do
      Realm.start_sim(1_000, {:test, :sim})
      Test.Realm.SimulationLoop |> GenServer.stop(:shutdown)
      assert_receive({:sim, started: false})
      wait_for_all()
      assert 0 <= Realm.get_root()
      assert false == Realm.started?()
    end

    @tag :skip
    test "data crash" do
      Realm.start_sim(1_000, {:test, :sim})
      Test.Realm.Data |> Agent.stop(:shutdown)
      wait_for_all()
      refute_receive({:sim, started: false})
      assert nil == Realm.get_root()
      assert false == Realm.started?()
    end

    @tag :skip
    test "command crash" do
      Realm.start_sim(1_000, {:test, :sim})
      Realm.crash()
      wait_for_all()
      assert_receive({:sim, started: false})
      assert 0 == Realm.get_root()
      assert false == Realm.started?()
    end
  end

  def wait_for_all() do
    Enum.all?([Test.Realm.CommandGuard, Test.Realm.SimulationLoop, Test.Realm.Data], fn process ->
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
