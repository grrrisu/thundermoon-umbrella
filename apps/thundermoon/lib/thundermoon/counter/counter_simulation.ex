defmodule Thundermoon.CounterSimulation do
  use GenServer

  alias Thundermoon.Counter
  alias ThundermoonWeb.Endpoint

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{sim: nil}}
  end

  def handle_call(:started?, _from, %{sim: sim} = state) do
    {:reply, not is_nil(sim), state}
  end

  def handle_cast(:start, %{sim: nil} = state) do
    send(self(), :tick)
    Endpoint.broadcast("counter", "sim", %{started: true})
    {:noreply, state}
  end

  def handle_cast(:start, state) do
    # already running
    {:noreply, state}
  end

  def handle_cast(:stop, %{sim: nil} = state) do
    # already stopped
    {:noreply, state}
  end

  def handle_cast(:stop, %{sim: sim} = state) do
    Process.cancel_timer(sim)
    Endpoint.broadcast("counter", "sim", %{started: false})
    {:noreply, %{state | sim: nil}}
  end

  def handle_info(:tick, state) do
    sim()
    counter_sim = Process.send_after(self(), :tick, 1000)
    {:noreply, %{state | sim: counter_sim}}
  end

  def sim() do
    Counter.inc(1)
  end
end
