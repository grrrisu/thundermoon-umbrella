defmodule Sim.Realm.Broadcaster do
  use GenServer

  alias Phoenix.PubSub

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl true
  def init(opts) do
    {:ok, topic: opts[:topic], pub_sub: opts[:pub_sub]}
  end

  def reduce(server \\ __MODULE__, event) do
    GenServer.call(server, {:reduce, event})
  end

  def handle_call({:reduce, event}, _from, state) do
    {:reply, PubSub.broadcast(state.pubsub, state.topic, event), state}
  end
end
