defmodule Sim.Realm.EventBus do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl true
  def init(opts) do
    {:ok, %{task_supervisor_name: opts[:task_supervisor_name], reducers: opts[:reducers]}}
  end

  def add_events(server, events) do
    GenServer.cast(server, {:add_events, events})
  end

  @impl true
  def handle_cast({:add_events, events}, state) do
    Enum.each(events, fn event -> reduce_event(event, state) end)
    {:noreply, state}
  end

  def reduce_event(event, state) do
    Task.Supervisor.async_stream_nolink(
      state.task_supervisor_name,
      state.reducers,
      fn {reducer_module, reducer} ->
        reducer_module.reduce(reducer, event)
      end
    )
    |> Stream.run()
  end
end
