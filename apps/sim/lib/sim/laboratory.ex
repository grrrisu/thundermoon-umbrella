defmodule Sim.Laboratory do
  alias Sim.Laboratory.Server

  def create(create_func, pub_sub, server \\ Server) do
    {:ok, entry} = GenServer.call(server, {:create, pub_sub})
    {:ok, object} = GenServer.call(entry.pid, {:create, create_func})
    {entry.id, object}
  end

  def object(id, server \\ Server) do
    call(id, :object, server)
  end

  def start(id, sim_func, server \\ Server) do
    call(id, {:start, sim_func}, server)
  end

  def stop(id, server \\ Server) do
    call(id, :stop, server)
  end

  def get(id, server \\ Server) do
    GenServer.call(server, {:get, id})
  end

  def update(id, key, value, server \\ Server) do
    GenServer.call(server, {:update, id, key, value})
  end

  def update_object(id, update_func, server \\ Server) when is_function(update_func) do
    GenServer.call(server, {:update_object, id, update_func})
  end

  def call(id, payload, server \\ Server) do
    case get(id, server) do
      {:error, :not_found} -> {:error, :not_found}
      entry -> GenServer.call(entry.pid, payload)
    end
  end

  def delete(id, server \\ Server) do
    GenServer.call(server, {:delete, id})
  end

  def clean(server \\ Server) do
    GenServer.call(server, :clean)
  end
end
