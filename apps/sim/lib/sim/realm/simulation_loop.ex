defmodule Sim.Realm.SimulationLoop do
  use GenServer

  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: opts[:name] || __MODULE__)
  end

  def init(:ok) do
    Logger.debug("start simulation loop")
    {:ok, %{sim: nil, sim_func: nil, realm_server: nil}}
  end

  def handle_call(:register_realm_server, {pid, _ref}, state) do
    {:reply, :ok, %{state | realm_server: Process.monitor(pid)}}
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

  def handle_cast({:sim_result, result}, state) do
    case result do
      :ok ->
        {:noreply, state}

      {:error, {reason, _}} ->
        Logger.warn(Exception.message(reason))
        {:noreply, stop(state)}
    end
  end

  def handle_info(:tick, %{realm_server: nil} = state) do
    Logger.warn("realm server not available -> retry")
    {:noreply, %{state | sim: create_next_tick(10)}}
  end

  def handle_info(:tick, state) do
    :ok = Sim.Realm.sim(state.sim_func)
    # TODO use another send_after to catch a timeout of sim
    {:noreply, %{state | sim: create_next_tick(100)}}
  end

  def handle_info({:DOWN, ref, :process, _object, reason}, %{realm_server: ref} = state) do
    Logger.warn("realm server ref removed from simulation loop")
    {:noreply, %{state | realm_server: nil}}
  end

  def handle_info({:DOWN, _ref, :process, _object, reason}, state) do
    {:noreply, state}
  end

  defp create_next_tick(delay) do
    Process.send_after(self(), :tick, delay)
  end

  def terminate(_reason, _state) do
    Sim.Realm.Data.set_running(false)
  end

  defp stop(state) do
    Logger.info("stop sim loop")
    :ok = Sim.Realm.Data.set_running(false)
    %{state | sim: nil}
  end
end
