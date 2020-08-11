defmodule Thundermoon.Memo.ServerTest do
  use ExUnit.Case

  alias Thundermoon.Memo
  alias Thundermoon.Memo.Server

  setup do
    %{
      server:
        start_supervised!(%{
          id: Thundermoon.Memo.ServerTest,
          start: {Thundermoon.Memo.Server, :start_link, [%{name: Thundermoon.Memo.ServerTest}]}
        })
    }
  end

  describe "create" do
    test "an entry", %{server: server} do
      assert {:ok, entry} = Memo.create(server)
      refute entry.id == nil
    end
  end

  describe "get" do
    setup(%{server: server}) do
      {:ok, entry} = Memo.create(server)
      %{entry: entry}
    end

    test "an existing entry", %{server: server, entry: entry} do
      assert entry == Memo.get(entry.id, server)
    end

    test "an unknown entry", %{server: server} do
      assert {:error, :not_found} == Memo.get("unknown", server)
    end
  end

  describe "update" do
    setup(%{server: server}) do
      {:ok, entry} = Memo.create(server)
      %{entry: entry}
    end

    test "with a new value", %{server: server, entry: entry} do
      assert %{foo: "bar"} = Memo.update(entry.id, :foo, "bar", server)
    end

    test "an existing value", %{server: server, entry: entry} do
      Memo.update(entry.id, :foo, "bar", server)
      assert %{foo: "bazbar"} = Memo.update(entry.id, :foo, "bazbar", server)
    end

    test "an unknown entry", %{server: server} do
      assert {:error, :not_found} == Memo.update("unknown", :foo, "bar", server)
    end
  end

  describe "delete" do
    test "an existing entry", %{server: server} do
      {:ok, entry} = Memo.create(server)
      assert :ok = Memo.delete(entry.id, server)
      assert {:error, :not_found} == Memo.get(entry.id, server)
    end

    test "an unknown entry", %{server: server} do
      assert {:error, :not_found} == Memo.delete("unknown", server)
    end
  end

  describe "clean" do
    test "all entries", %{server: server} do
      {:ok, entry} = Memo.create(server)
      assert :ok = Memo.clean(server)
      assert {:error, :not_found} == Memo.get(entry.id, server)
    end
  end
end
