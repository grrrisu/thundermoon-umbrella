defmodule Sim.Realm.SimulationLoop do
  use GenServer

  require Logger

  alias Sim.Realm.CommandGuard

  alias Phoenix.PubSub

  # --- client ---

  def start(server, delay \\ 100, command \\ %{command: :sim}) do
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
    GenServer.start_link(__MODULE__, {opts[:command_guard_module], opts[:pubsub], opts[:topic]},
      name: opts[:name]
    )
  end

  def init({command_guard_module, pubsub, topic}) do
    Logger.debug("start simulation loop")

    {:ok,
     %{
       pubsub: pubsub,
       topic: topic,
       next_tick: nil,
       delay: 1_000,
       command: %{command: :sim},
       command_guard_module: command_guard_module
     }}
  end

  def handle_cast({:start, delay, command}, %{next_tick: nil} = state) do
    Logger.info("starting simulation ...")
    broadcast(state, true)

    {:noreply,
     %{state | next_tick: create_next_tick(state.delay), delay: delay, command: command}}
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
    :ok = CommandGuard.receive(state.command_guard_module, state.command)
    {:noreply, %{state | next_tick: create_next_tick(state.delay)}}
  end

  defp create_next_tick(delay) do
    Process.send_after(self(), :tick, delay)
  end

  def terminate(_reason, state) do
    broadcast(state, false)
  end

  defp set_stop(state) do
    Logger.info("stop sim loop")
    broadcast(state, false)
    %{state | next_tick: nil}
  end

  defp broadcast(state, started) do
    PubSub.broadcast(state.pubsub, state.topic, {:sim, started: started})
  end
end
