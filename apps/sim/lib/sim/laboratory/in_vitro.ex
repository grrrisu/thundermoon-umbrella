defmodule Sim.Laboratory.InVitro do
  @moduledoc """
  All in one server for testing simulations.
  Data, SimLoop and Access are all here, if the server crashes the whole state is loss.
  """
  use GenServer, restart: :transient

  require Logger

  alias Phoenix.PubSub

  @sim_interval 1000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, {opts[:entry_id], opts[:pub_sub]})
  end

  def init({id, pub_sub}) do
    {:ok, %{id: id, pub_sub: pub_sub, object: nil, sim_func: nil, sim_process: nil}}
  end

  def handle_call({:create, create_func}, _from, state) do
    Logger.debug("create object for #{state.id}")
    object = create_func.()
    {:reply, {:ok, object}, %{state | object: object}}
  end

  def handle_call(:object, _from, state) do
    {:reply, state.object, state}
  end

  def handle_call({:update_object, update_func}, _from, state) do
    object = update(state, update_func)
    {:reply, {:ok, object}, %{state | object: object}}
  end

  def handle_call({:start, sim_func}, _from, %{sim_process: nil} = state) do
    broadcast(state, {:sim, started: true})
    Logger.debug("sim started for #{state.id}")
    {:reply, :ok, %{state | sim_func: sim_func, sim_process: next_sim_call()}}
  end

  def handle_call({:start, _sim_func}, _from, state) do
    {:reply, :no_change, state}
  end

  def handle_call(:stop, _from, %{sim_process: nil} = state) do
    {:reply, :no_change, state}
  end

  def handle_call(:stop, _from, state) do
    Process.cancel_timer(state.sim_process)
    broadcast(state, {:sim, started: false})
    Logger.debug("sim stopped for #{state.id}")
    {:reply, :ok, %{state | sim_process: nil}}
  end

  def handle_info(:tick, state) do
    {:noreply, %{state | object: sim(state), sim_process: next_sim_call()}}
  end

  def next_sim_call() do
    Process.send_after(self(), :tick, @sim_interval)
  end

  defp update(state, update_func) do
    state.object
    |> update_func.()
    |> broadcast_sim_changes(state)
  end

  defp sim(state) do
    update(state, state.sim_func)
  end

  defp broadcast_sim_changes(object, state) do
    :ok = broadcast(state, {:update, data: object})
    object
  end

  defp broadcast(state, payload) do
    PubSub.broadcast(state.pub_sub, state.id, payload)
  end
end
