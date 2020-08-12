defmodule Sim.Laboratory.RegistryTest do
  use ExUnit.Case

  alias Sim.Laboratory.Registry

  describe "create" do
    test "an entry" do
      assert {{:ok, entry}, state} = Registry.create(%{})
      assert state == %{entry.id => entry}
      assert is_pid(entry.pid)
      assert %{id: _, pid: _, ref: _, timestamp: _} = entry
    end
  end

  describe "get" do
    setup do
      {{:ok, entry}, state} = Registry.create(%{})
      %{state: state, entry: entry}
    end

    test "an existing entry", %{state: state, entry: entry} do
      assert entry == Registry.get(state, entry.id)
    end

    test "an unknown entry", %{state: state} do
      assert {:error, :not_found} == Registry.get(state, "unknown")
    end
  end

  describe "update" do
    setup do
      {{:ok, entry}, state} = Registry.create(%{})
      %{state: state, entry: entry}
    end

    test "with a new value", %{state: state, entry: entry} do
      {entry, _state} = Registry.update(state, entry.id, :foo, "bar")
      assert %{foo: "bar"} = entry
    end

    test "an existing value", %{state: state, entry: entry} do
      {entry, state} = Registry.update(state, entry.id, :foo, "bar")
      {entry, _state} = Registry.update(state, entry.id, :foo, "bazbar")
      assert %{foo: "bazbar"} = entry
    end

    test "an unknown entry", %{state: state} do
      assert {{:error, :not_found}, state} = Registry.update(state, "unknown", :foo, "bar")
    end
  end

  describe "delete" do
    test "an existing entry" do
      {{:ok, entry}, state} = Registry.create(%{})
      assert {:ok, state} = Registry.delete(state, entry.id)
      assert {:error, :not_found} == Registry.get(state, entry.id)
    end

    test "an unknown entry" do
      assert {{:error, :not_found}, %{}} == Registry.delete(%{}, "unknown")
    end
  end

  describe "prune" do
    test "old entries" do
      timestamps = %{
        1 => DateTime.utc_now() |> DateTime.add(-4000),
        2 => DateTime.utc_now() |> DateTime.add(-500),
        3 => DateTime.utc_now() |> DateTime.add(-7200)
      }

      registry =
        Enum.reduce(1..3, %{}, fn item, state ->
          {{:ok, entry}, state} = Registry.create(state)
          put_in(state[entry.id][:timestamp], timestamps[item])
        end)
        |> Registry.prune()

      assert Enum.count(registry) == 1
    end
  end
end
