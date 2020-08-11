defmodule Thundermoon.Memo.Server do
  use GenServer

  alias Thundermoon.Memo.Registry

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call(:create, _from, state) do
    entry = Registry.create()
    {:reply, {:ok, entry}, update_state(state, entry)}
  end

  def handle_call({:get, id}, _from, state) do
    case Map.get(state, id) do
      nil -> {:reply, {:error, :not_found}, state}
      entry -> {:reply, entry, state}
    end
  end

  def handle_call({:update, id, key, value}, _from, state) do
    case Map.get(state, id) do
      nil ->
        {:reply, {:error, :not_found}, state}

      entry ->
        entry = Registry.update(entry, key, value)
        {:reply, entry, update_state(state, entry)}
    end
  end

  def handle_call({:delete, id}, _from, state) do
    case Map.get(state, id) do
      nil -> {:reply, {:error, :not_found}, state}
      _entry -> {:reply, :ok, Map.delete(state, id)}
    end
  end

  def handle_call({:delete, id}, _from, state) do
    {:reply, {:error, :not_found}, state}
  end

  def handle_call(:clean, _from, state) do
    {:reply, :ok, %{}}
  end

  defp update_state(state, entry) do
    Map.put(state, entry.id, entry)
  end
end
