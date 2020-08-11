defmodule Thundermoon.Memo do
  alias Thundermoon.Memo.Server

  def create(server \\ Server) do
    GenServer.call(server, :create)
  end

  def get(id, server \\ Server) do
    GenServer.call(server, {:get, id})
  end

  def update(id, key, value, server \\ Server) do
    GenServer.call(server, {:update, id, key, value})
  end

  def delete(id, server \\ Server) do
    GenServer.call(server, {:delete, id})
  end

  def clean(server \\ Server) do
    GenServer.call(server, :clean)
  end
end
