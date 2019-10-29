defmodule Thundermoon.SimContainer do
  use GenServer, restart: :temporary

  alias Thundermoon.Session

  def start_link(supervisor_module) do
    GenServer.start_link(__MODULE__, supervisor_module, name: __MODULE__)
  end

  def init(supervisor_module) do
    {:ok, %{sessions: %{}, supervisor_module: supervisor_module}}
  end

  def add(args) do
    GenServer.call(__MODULE__, {:add, args})
  end

  def remove(session_id) do
    GenServer.call(__MODULE__, {:remove, session_id})
  end

  def sim(func) do
    GenServer.call(__MODULE__, {:sim, func})
  end

  def handle_call({:add, %{object_module: object_module}}, _from, state) do
    {:ok, pid} = DynamicSupervisor.start_child(state.supervisor_module, object_module)
    ref = Process.monitor(pid)
    session = %Session{ref: ref, pid: pid, running: true}
    new_sessions = Map.put_new(state.sessions, ref, session)
    {:reply, {:ok, ref}, %{state | sessions: new_sessions}}
  end

  def handle_call({:remove, session_ref}, _from, state) do
    new_sessions = Map.delete(state.sessions, session_ref)
    {:reply, session_ref, %{state | sessions: new_sessions}}
  end

  def handle_call({:sim, func}, _from, state) do
    Enum.each(state.sessions, fn {_ref, session} ->
      if session.running do
        # TODO use Task
        func.(session)
      end
    end)
  end
end
