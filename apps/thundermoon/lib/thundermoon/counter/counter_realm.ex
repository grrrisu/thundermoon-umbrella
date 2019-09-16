defmodule Thundermoon.CounterRealm do
  @moduledoc """
  This is the static part of the counter realm.
  It creates and recreates the counter.
  """
  use GenServer

  alias Thundermoon.CounterRoot
  alias Thundermoon.CounterSupervisor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    # we don't create the counter immediately as
    # the endpoint pubsub is not started at this point
    {:ok, %{root: nil, sim: nil}}
  end

  def handle_call(:create, _from, %{root: nil} = state) do
    root = create_counter()
    {:reply, {:ok, root.pid}, %{state | root: root}}
  end

  def handle_call(:create, _from, %{root: root} = state) do
    {:reply, {:ok, root.pid}, state}
  end

  def handle_call(:get_root, _from, state) do
    {:reply, state.root.pid, state}
  end

  def handle_cast(:start, %{sim: nil} = state) do
    Process.send(self(), :sim_counter, 1000)
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
    {:noreply, %{state | sim: nil}}
  end

  def handle_info(:sim_counter, state) do
    CounterRoot.inc(state.root.pid, 1)
    counter_sim = Process.send_after(self(), :sim_counter, 1000)
    {:noreply, %{state | sim: counter_sim}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    root =
      cond do
        nil == state.root -> state
        ref == state.root.ref -> create_counter()
        true -> state
      end

    {:noreply, %{state | root: root}}
  end

  defp create_counter do
    {:ok, pid} = DynamicSupervisor.start_child(CounterSupervisor, CounterRoot)

    ref = Process.monitor(pid)
    %{ref: ref, pid: pid}
  end
end
