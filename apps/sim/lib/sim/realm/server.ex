defmodule Sim.Realm.Server do
  @moduledoc """
  This acts as a global lock against the data
  """
  use GenServer

  alias Sim.Realm.{Data, SimulationLoop}

  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:name],
      name: (opts[:name] && server_name(opts[:name])) || __MODULE__
    )
  end

  def init(name) do
    Logger.debug("start realm server")
    # FIXME use {:ok, state, continue: :register_to_simulation_loop}
    Process.send_after(self(), :register_to_simulation_loop, 1)
    {:ok, %{name: name}}
  end

  def handle_call(:get_root, _from, state) do
    {:reply, Data.get_data(state), state}
  end

  def handle_call({:set_root, data}, _from, state) do
    {:reply, Data.set_data(state, data), state}
  end

  def handle_call({:create, factory, config}, _from, state) do
    with data <- factory.create(config),
         :ok <- Data.set_data(state, data) do
      {:reply, :ok, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:start_sim, func}, _from, state) do
    :ok = SimulationLoop.send_start(state, func)
    {:reply, :ok, state}
  end

  def handle_call(:stop_sim, _from, state) do
    :ok = SimulationLoop.send_stop(state)
    {:reply, :ok, state}
  end

  def handle_call(:started?, _from, state) do
    {:reply, Data.running?(state), state}
  end

  def handle_cast({:sim, func}, state) do
    result =
      case execute_task(func, state) do
        {:ok, _} -> :ok
        {:exit, reason} -> {:error, reason}
        nil -> {:error, :timeout}
      end

    SimulationLoop.send_sim_result(state, result)
    {:noreply, state}
  end

  def handle_info(:register_to_simulation_loop, state) do
    SimulationLoop.register_realm_server(state)
    {:noreply, state}
  end

  defp execute_task(sim_func, state) when is_function(sim_func) do
    Task.Supervisor.async_nolink(realm_task_supervisor(state), fn ->
      Data.get_data(state)
      |> sim_func.()
      |> Data.set_data(state)
    end)
    |> Task.yield()
  end

  defp server_name(name) do
    Module.concat(name, "RealmServer")
  end

  defp realm_task_supervisor(state) do
    Module.concat(state.name, "TaskSupervisor")
  end
end
