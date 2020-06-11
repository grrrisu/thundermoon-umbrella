defmodule Sim.Realm.SimulationLoop do
  use GenServer

  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    {:ok, %{sim: nil, sim_func: nil}}
  end

  def handle_cast({:start, func}, %{sim: nil} = state) do
    Logger.info("start sim loop")
    state = Map.put(state, :sim_func, func)
    send(self(), :tick)
    {:noreply, state}
  end

  def handle_cast({:start, _func}, state) do
    # already running
    {:noreply, state}
  end

  def handle_cast(:stop, %{sim: nil} = state) do
    # already stopped
    {:noreply, state}
  end

  def handle_cast(:stop, %{sim: sim} = state) do
    Process.cancel_timer(sim)
    {:noreply, stop(state)}
  end

  def handle_info(:tick, state) do
    case Sim.Realm.sim(state.sim_func) do
      :ok ->
        next_tick = Process.send_after(self(), :tick, 100)
        {:noreply, %{state | sim: next_tick}}

      {:error, {reason, _}} ->
        Logger.warn(Exception.message(reason))
        {:noreply, stop(state)}
    end
  end

  def terminate(_reason, _state) do
    Sim.Realm.Data.set_running(false)
  end

  defp stop(state) do
    Logger.info("stop sim loop")
    %{state | sim: nil}
  end
end
