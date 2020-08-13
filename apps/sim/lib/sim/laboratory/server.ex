defmodule Sim.Laboratory.Server do
  use GenServer

  alias Sim.Laboratory.Registry

  # 1 min in milliseconds
  @prune_interval 60 * 1000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    schedule_next_prune()
    {:ok, %{}}
  end

  def handle_call({:create, pub_sub}, _from, state) do
    {response, state} = Registry.create(state, pub_sub)
    {:reply, response, state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, Registry.get(state, id), state}
  end

  def handle_call({:update, id, key, value}, _from, state) do
    {response, state} = Registry.update(state, id, key, value)
    {:reply, response, state}
  end

  def handle_call({:delete, id}, _from, state) do
    {response, state} = Registry.delete(state, id)
    {:reply, response, state}
  end

  def handle_call(:clean, _from, state) do
    {:reply, :ok, %{}}
  end

  def handle_info(:prune, state) do
    new_state = Registry.prune(state)
    schedule_next_prune()
    {:noreply, new_state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    case Registry.find_by_ref(state, ref) do
      nil -> {:noreply, state}
      entry -> {:noreply, Map.delete(state, entry.id)}
    end
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end

  defp schedule_next_prune do
    Process.send_after(self(), :prune, @prune_interval)
  end
end
