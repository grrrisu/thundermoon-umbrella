defmodule Sim.Realm.SimulationLoop do
  use GenServer

  require Logger

  alias Sim.Realm.Data

  # --- client ---

  def register_realm_server(%{name: name}) do
    server_name(name) |> GenServer.call(:register_realm_server)
  end

  def send_start(%{name: name}, func) do
    :ok = server_name(name) |> GenServer.cast({:start, func})
  end

  def send_stop(%{name: name}) do
    :ok = server_name(name) |> GenServer.cast(:stop)
  end

  def send_sim_result(%{name: name}, result) do
    :ok = server_name(name) |> GenServer.cast({:sim_result, result})
  end

  defp server_name(name) do
    Module.concat(name, "SimulationLoop")
  end

  # -- server ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:name],
      name: (opts[:name] && server_name(opts[:name])) || __MODULE__
    )
  end

  def init(name) do
    Logger.debug("start simulation loop")
    {:ok, %{sim: nil, realm_server: nil, name: name}}
  end

  def handle_call(:register_realm_server, {pid, _ref}, state) do
    {:reply, :ok, %{state | realm_server: Process.monitor(pid)}}
  end

  def handle_cast({:start, func}, %{sim: nil} = state) do
    Logger.info("start sim loop")
    :ok = Data.set_running(state, true)
    send(self(), {:tick, func})
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

      {:error, :timeout} ->
        Logger.warn("sim task exceeded timeout")
        {:noreply, state}

      {:error, {reason, _}} ->
        Logger.warn(Exception.message(reason))
        {:noreply, stop(state)}
    end
  end

  def handle_info({:tick, _}, %{realm_server: nil} = state) do
    Logger.warn("realm server not available -> retry")
    {:noreply, %{state | sim: create_next_tick(10)}}
  end

  def handle_info({:tick, func}, state) do
    :ok = Sim.Realm.sim(func)
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

  def terminate(_reason, state) do
    Data.set_running(state, false)
  end

  defp stop(state) do
    Logger.info("stop sim loop")
    :ok = Data.set_running(state, false)
    %{state | sim: nil}
  end
end
