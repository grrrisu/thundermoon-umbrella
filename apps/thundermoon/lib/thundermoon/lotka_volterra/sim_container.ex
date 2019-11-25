defmodule Thundermoon.SimContainer do
  use GenServer

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

  def get_sessions() do
    GenServer.call(__MODULE__, :get_sessions)
  end

  def handle_call({:add, %{object_module: object_module}}, {from_id, _}, state) do
    {:ok, pid} = DynamicSupervisor.start_child(state.supervisor_module, object_module)
    ref = Process.monitor(pid)
    listener_ref = Process.monitor(from_id)

    session = %Session{
      subject_pid: pid,
      subject_ref: ref,
      listener_pid: from_id,
      listener_ref: listener_ref,
      running: true
    }

    new_sessions = Map.put_new(state.sessions, ref, session)
    {:reply, {:ok, ref}, %{state | sessions: new_sessions}}
  end

  def handle_call({:remove, session_ref}, _from, state) do
    new_sessions = Map.delete(state.sessions, session_ref)
    {:reply, session_ref, %{state | sessions: new_sessions}}
  end

  def handle_call(:get_sessions, _from, state) do
    {:reply, Map.values(state.sessions), state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{sessions: sessions} = state) do
    new_sessions =
      case Enum.find(sessions, fn {key, session} -> session.listener_ref == ref end) do
        {key, value} -> sessions = Map.delete(sessions, key)
        nil -> sessions
      end

    {:noreply, %{state | sessions: new_sessions}}
  end
end
