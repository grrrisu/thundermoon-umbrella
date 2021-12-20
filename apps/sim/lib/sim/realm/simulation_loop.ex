defmodule Sim.Realm.SimulationLoop do
  use GenServer

  require Logger

  alias Sim.Realm.CommandBus

  # --- client ---

  def start(server, delay, command) do
    GenServer.cast(server, {:start, delay, command})
  end

  def stop(server) do
    :ok = GenServer.cast(server, :stop)
  end

  def running?(server) do
    GenServer.call(server, :running?)
  end

  # -- server ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    Logger.debug("start simulation loop")

    {:ok,
     %{
       next_tick: nil,
       delay: 1_000,
       command: {:sim, :tick},
       command_bus_module: opts[:command_bus_module]
     }}
  end

  def handle_cast({:start, delay, command}, %{next_tick: nil} = state) do
    Logger.info("starting simulation ...")
    send(self(), :tick)
    {:noreply, %{state | delay: delay, command: command}}
  end

  def handle_cast({:start, _delay, _command}, state) do
    # already running
    {:noreply, state}
  end

  def handle_cast(:stop, %{next_tick: nil} = state) do
    # already stopped
    {:noreply, state}
  end

  def handle_cast(:stop, %{next_tick: next_tick} = state) do
    Process.cancel_timer(next_tick)
    {:noreply, set_stop(state)}
  end

  def handle_call(:running?, _from, state) do
    {:reply, not is_nil(state.next_tick), state}
  end

  def handle_info(:tick, state) do
    :ok = CommandBus.dispatch(state.command_bus_module, state.command)
    {:noreply, %{state | next_tick: create_next_tick(state.delay)}}
  end

  defp create_next_tick(delay) do
    Process.send_after(self(), :tick, delay)
  end

  defp set_stop(state) do
    Logger.info("stop sim loop")
    %{state | next_tick: nil}
  end
end
