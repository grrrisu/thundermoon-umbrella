defmodule Sim.Realm do
  @moduledoc """
  This is the static part of the realm.
  It creates the root
  """
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {opts[:supervisor_module], opts[:root_module]},
      name: opts[:name]
    )
  end

  def init({supervisor_module, root_module}) do
    # we don't create the counter immediately as
    # the endpoint pubsub is not started at this point
    {:ok, %{root: nil, supervisor_module: supervisor_module, root_module: root_module}}
  end

  def handle_call(:create, _from, %{root: nil} = state) do
    root = create_root(state)
    {:reply, {:ok, root.pid}, %{state | root: root}}
  end

  def handle_call(:create, _from, %{root: root} = state) do
    {:reply, {:ok, root.pid}, state}
  end

  def handle_call(:get_root, _from, state) do
    {:reply, state.root.pid, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    root =
      cond do
        nil == state.root -> state
        ref == state.root.ref -> create_root(state)
        true -> state
      end

    {:noreply, %{state | root: root}}
  end

  defp create_root(state) do
    {:ok, pid} = DynamicSupervisor.start_child(state.supervisor_module, state.root_module)

    ref = Process.monitor(pid)
    %{ref: ref, pid: pid}
  end
end
