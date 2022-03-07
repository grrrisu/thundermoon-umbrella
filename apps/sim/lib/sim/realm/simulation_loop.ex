# copied from thundermoon for now
defmodule Sim.Realm.SimulationLoop do
  use GenServer

  require Logger

  # --- client ---

  def start(server \\ __MODULE__, delay, tick_function) do
    GenServer.cast(server, {:start, delay, tick_function})
  end

  def stop(server \\ __MODULE__) do
    :ok = GenServer.cast(server, :stop)
  end

  def running?(server \\ __MODULE__) do
    GenServer.call(server, :running?)
  end

  # -- server ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(_opts) do
    Logger.debug("start simulation loop")

    {:ok,
     %{
       next_tick: nil,
       delay: 1_000,
       tick_function: nil
     }}
  end

  def handle_cast({:start, delay, tick_function}, %{next_tick: nil} = state) do
    Logger.info("starting simulation ...")
    send(self(), :tick)
    {:noreply, %{state | delay: delay, tick_function: tick_function}}
  end

  def handle_cast({:start, _delay, _tick_function}, state) do
    # already running
    {:noreply, state}
  end

  def handle_cast(:stop, %{next_tick: nil} = state) do
    # already stopped
    {:noreply, state}
  end

  def handle_cast(:stop, %{next_tick: next_tick} = state) do
    Process.cancel_timer(next_tick)
    {:noreply, %{state | next_tick: nil}}
  end

  def handle_call(:running?, _from, state) do
    {:reply, not is_nil(state.next_tick), state}
  end

  def handle_info(:tick, state) do
    {:noreply, %{state | next_tick: state.tick_function.() |> set_next_tick(state.delay)}}
  end

  defp set_next_tick(:ok, delay) do
    Process.send_after(self(), :tick, delay)
  end

  defp set_next_tick(:stop, _delay) do
    Logger.info("stop sim loop")
    nil
  end
end
