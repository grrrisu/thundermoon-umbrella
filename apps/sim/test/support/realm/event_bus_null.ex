defmodule Test.EventBusNull do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def get_events(server) do
    GenServer.call(server, {:get_events})
  end

  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_cast({:add_events, events}, state) do
    {:noreply, events}
  end

  def handle_call({:get_events}, _from, state) do
    {:reply, state, state}
  end
end
