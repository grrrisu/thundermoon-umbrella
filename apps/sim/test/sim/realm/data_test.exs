defmodule Sim.Realm.DataTest do
  use ExUnit.Case

  require Logger

  alias Sim.Realm.Data

  setup do
    agent = start_supervised!(Sim.Realm.Data)
    %{agent: agent, world: %{world: %{city: %{factory: %{wood: 5}}}}}
  end

  describe "init" do
    test "data", %{agent: agent} do
      assert nil == Data.get_data(agent)
    end
  end

  describe "get" do
    test "direct", %{agent: agent} do
      assert :ok = Data.set_data(agent, %{world: "simple"})
      assert %{world: "simple"} == Data.get_data(agent)
    end

    test "with a function", %{agent: agent, world: world} do
      assert :ok = Data.set_data(agent, world)
      wood = Data.get_data(agent, fn data -> get_in(data, [:world, :city, :factory, :wood]) end)
      assert 5 == wood
    end
  end

  describe "set" do
    test "with a function", %{agent: agent} do
      assert :ok = Data.set_data(agent, fn -> 5 + 2 end)
      assert 7 == Data.get_data(agent)
    end
  end

  describe "update" do
    test "with a function", %{agent: agent} do
      assert :ok = Data.set_data(agent, 5)
      assert :ok = Data.update(agent, &{:ok, &1 + 4})
      assert 9 == Data.get_data(agent)
    end

    test "with a function returning events", %{agent: agent} do
      assert :ok = Data.set_data(agent, 5)
      assert {:ok, [changed: 9]} == Data.update(agent, &{:ok, &1 + 4, [changed: &1 + 4]})
      assert 9 == Data.get_data(agent)
    end

    test "failed function", %{agent: agent} do
      assert :ok = Data.set_data(agent, 5)
      assert {:error, "failed"} = Data.update(agent, fn _ -> {:error, "failed"} end)
      assert 5 == Data.get_data(agent)
    end

    test "failed fallback", %{agent: agent} do
      assert :ok = Data.set_data(agent, 5)
      assert {:error, _} = Data.update(agent, fn _ -> :unknown end)
      assert 5 == Data.get_data(agent)
    end
  end
end
