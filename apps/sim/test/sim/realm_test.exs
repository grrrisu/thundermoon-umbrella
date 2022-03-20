defmodule Sim.RealmTest do
  use ExUnit.Case, async: false

  alias Phoenix.PubSub

  alias Test.Realm

  def reduce(events) do
    Enum.map(events, fn event ->
      Phoenix.PubSub.broadcast(:test_pub_sub, "Test.Realm", event)
    end)
  end

  setup do
    start_supervised!({PubSub, name: :test_pub_sub})

    start_supervised!(
      {Sim.Realm.Supervisor,
       name: Test.Realm,
       domain_services: [
         {Test.CommandHandler, partition: :test, max_demand: 5},
         {Test.RealmCommandHandler, partition: :user, max_demand: 1}
       ],
       reducers: [Sim.RealmTest]}
    )

    PubSub.subscribe(:test_pub_sub, "Test.Realm")
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
      assert :ok = Realm.start_sim(1000, {:test, :tick})
      assert_receive({:sim, started: true})
    end

    test "stop" do
      assert :ok = Realm.start_sim(1000, {:test, :tick})
      assert :ok = Realm.stop_sim()
      assert_receive({:sim, started: false})
    end

    test "sim" do
      assert :ok = Realm.start_sim(10, {:test, :tick})
      assert_receive({:update, data: 1})
      # wait one sim cycle
      Process.sleep(10)
      assert_receive({:update, data: 2})
    end

    test "started?" do
      assert false == Realm.started?()
      Realm.start_sim(10, {:test, :tick})
      Process.sleep(1)
      assert true == Realm.started?()
      Realm.stop_sim()
      Process.sleep(1)
      assert false == Realm.started?()
    end

    test "crashed command stops sim" do
      Realm.start_sim(1000, {:test, :tick})
      Realm.crash()
      assert_receive({:error, "crash command"})
      # TODO assert false == Realm.started?()
    end
  end

  describe "echo" do
    test "receive echo" do
      assert :ok = Realm.echo("holidoo")
      assert_receive({:echoed, [payload: "holidoo"]})
    end

    test "receive echo twice" do
      assert :ok = Realm.echo_twice("holidoo")
      assert_receive({:echoed, [payload: "holidoo holidoo"]})
    end
  end
end
