defmodule Sim.SimulationLoop do
  use GenServer

  alias Phoenix.PubSub

  require Logger

  def start_link(broadcaster, topic, name) do
    GenServer.start_link(__MODULE__, {broadcaster, topic}, name: name)
  end

  def init({broadcaster, topic}) do
    {:ok, %{sim: nil, topic: topic, broadcaster: broadcaster}}
  end

  def handle_call(:started?, _from, %{sim: sim} = state) do
    {:reply, not is_nil(sim), state}
  end

  def handle_cast({:start, func}, %{sim: nil} = state) do
    Logger.info("start sim loop")
    state = Map.put(state, :func, func)
    send(self(), :tick)
    PubSub.broadcast(state.broadcaster, state.topic, {:sim, started: true})
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
    Logger.info("stop sim loop")
    Process.cancel_timer(sim)
    PubSub.broadcast(state.broadcaster, state.topic, {:sim, started: false})
    {:noreply, %{state | sim: nil}}
  end

  def handle_info(:tick, state) do
    # TODO run in a Task
    # GenServer.call(Grid, :sim)
    :ok = state.func.()
    next_tick = Process.send_after(self(), :tick, 100)
    {:noreply, %{state | sim: next_tick}}
  end
end
