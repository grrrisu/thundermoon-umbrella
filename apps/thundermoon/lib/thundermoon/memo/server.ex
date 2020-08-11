defmodule Thundermoon.Memo.Server do
  use GenServer

  alias Thundermoon.Memo.Registry

  # 1 min in milliseconds
  @prune_interval 60 * 1000

  # 1 hour in seconds
  @expires_in 60 * 60

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    schedule_next_prune()
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

  def handle_info(:prune, state) do
    new_state = prune(state)
    schedule_next_prune()
    {:noreply, new_state}
  end

  def prune(registry) do
    expire_date =
      DateTime.utc_now()
      |> DateTime.add(-@expires_in)

    registry
    |> Map.values()
    |> Enum.reject(&(DateTime.compare(&1.timestamp, expire_date) == :lt))
    |> Map.new(&{&1.id, &1})
  end

  defp schedule_next_prune do
    Process.send_after(self(), :prune, @prune_interval)
  end

  defp update_state(state, entry) do
    Map.put(state, entry.id, entry)
  end
end
