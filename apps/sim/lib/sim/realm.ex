defmodule Sim.Realm do
  @moduledoc """
  This is the static part of the realm.
  It creates the root
  """
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {opts[:supervisor_module]}, name: opts[:name])
  end

  def init({supervisor_module}) do
    # we don't create the counter immediately as
    # the endpoint pubsub is not started at this point
    {:ok, %{root: nil, supervisor_module: supervisor_module}}
  end

  def handle_call({:create, root_module, args}, _from, %{root: nil} = state) do
    state = Map.merge(state, %{root_module: root_module, create_args: args})
    root = create_root(state)
    {:reply, {:ok, root.pid}, %{state | root: root}}
  end

  def handle_call({:create, _root_module, _args}, _from, %{root: root} = state) do
    {:reply, {:ok, root.pid}, state}
  end

  def handle_call(:get_root, _from, %{root: nil} = state) do
    {:reply, nil, state}
  end

  def handle_call(:get_root, _from, state) do
    {:reply, state.root.pid, state}
  end

  def handle_call(:restart_root, _from, %{root: nil} = state) do
    {:reply, :ok, state}
  end

  def handle_call(:restart_root, _from, state) do
    Logger.info("terminate root #{state.root_module}")
    :ok = DynamicSupervisor.terminate_child(state.supervisor_module, state.root.pid)
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    root =
      cond do
        nil == state.root -> nil
        ref == state.root.ref -> create_root(state)
        true -> state.root
      end

    {:noreply, %{state | root: root}}
  end

  defp create_root(state) do
    Logger.info("create root module #{state.root_module}")

    child_spec = %{
      id: state.root_module,
      start: {state.root_module, :start_link, [state.create_args]}
    }

    {:ok, pid} = DynamicSupervisor.start_child(state.supervisor_module, child_spec)

    ref = Process.monitor(pid)
    %{ref: ref, pid: pid}
  end
end
