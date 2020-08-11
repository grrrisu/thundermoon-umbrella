defmodule Sim.Laboratory.InVitro do
  @moduledoc """
  All in one server for testing simulations.
  Data, SimLoop and Access are all here, if the server crashes the whole state is loss.
  """
  use GenServer, restart: :transient

  @sim_interval 60 * 1000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{object: nil, sim_func: nil, sim_process: nil}}
  end

  def handle_call({:create, create_func}, _from, state) do
    {:reply, object, %{state | object: create_func.()}}
  end

  def handle_call({:start, sim_func}, _from, %{sim_process: nil} = state) do
    {:reply, :ok, %{state | sim_func: sim_func, sim_process: next_sim_call()}}
  end

  def handle_call({:start, _sim_func}, _from, state) do
    {:reply, :no_change, state}
  end

  def handle_call(:stop, _from, %{sim_process: nil}) do
    {:reply, :no_change, state}
  end

  def handle_call(:stop, _from, state) do
    :ok = Process.cancel_timer(state.sim_process)
    {:reply, :ok, %{state | sim_process: nil}}
  end

  def handle_info(:tick, state) do
    {:noreply, %{state | object: sim(state), sim_process: next_sim_call()}}
  end

  def next_sim_call() do
    Process.send_after(self(), :tick, @sim_interval)
  end

  defp sim(state) do
    state.object
    |> state.sim_func.()
  end
end
