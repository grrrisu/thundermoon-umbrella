defmodule Sim.RealmTest do
  use ExUnit.Case, async: false

  alias Phoenix.PubSub

  alias Test.Realm

  require Logger

  setup do
    start_supervised!({PubSub, name: :test_pub_sub})

    start_supervised!(
      {Sim.Realm.Supervisor,
       name: Test.Realm,
       domain_services: [
         %{test: Test.CommandHandler, realm: Test.CommandHandler, sim: Test.CommandHandler}
       ],
       pub_sub: :test_pub_sub}
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
      assert_receive({:update, data: 1})
      # wait one sim cycle
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

    test "crashed command stops sim" do
      Realm.start_sim()
      Realm.crash()
      assert_receive({:sim, started: false})
      assert false == Realm.started?()
    end
  end
end
