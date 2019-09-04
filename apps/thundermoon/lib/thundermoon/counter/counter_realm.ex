defmodule Thundermoon.CounterRealm do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def create() do
    GenServer.call(__MODULE__, :create)
  end

  def init(:ok) do
    # we don't create the counter immediately as
    # the endpoint pubsub is not started at this point
    {:ok, nil}
  end

  def handle_call(:create, _from, nil) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        Thundermoon.CounterSupervisor,
        {Thundermoon.Counter, name: Thundermoon.Counter}
      )

    {:reply, :ok, pid}
  end

  def handle_call(:create, _from, pid) do
    {:reply, :ok, pid}
  end
end
