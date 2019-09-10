defmodule Thundermoon.CounterRealm do
  use GenServer

  alias Thundermoon.Counter

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def create() do
    GenServer.call(__MODULE__, :create)
  end

  def get_counter() do
    GenServer.call(__MODULE__, :get_counter)
  end

  def get_digits() do
    get_counter() |> Counter.get_digits()
  end

  def inc(digit) do
    get_counter() |> Counter.inc(digit)
  end

  def dec(digit) do
    get_counter() |> Counter.dec(digit)
  end

  def init(:ok) do
    # we don't create the counter immediately as
    # the endpoint pubsub is not started at this point
    {:ok, nil}
  end

  def handle_call(:create, _from, nil) do
    state = create_counter()
    {:reply, {:ok, state.pid}, state}
  end

  def handle_call(:create, _from, state) do
    {:reply, {:ok, state.pid}, state}
  end

  def handle_call(:get_counter, _from, state) do
    {:reply, state.pid, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    state =
      cond do
        ref == state.ref -> create_counter()
        true -> state
      end

    {:noreply, state}
  end

  defp create_counter do
    {:ok, pid} = DynamicSupervisor.start_child(Thundermoon.CounterSupervisor, Thundermoon.Counter)
    ref = Process.monitor(pid)
    %{ref: ref, pid: pid}
  end
end
