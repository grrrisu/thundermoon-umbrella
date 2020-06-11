defmodule Sim.Realm.Server do
  @moduledoc """
  This is the static part of the realm.
  It creates the root
  """
  use GenServer

  alias Phoenix.PubSub
  alias Sim.Realm.{Data, SimulationLoop}

  require Logger

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, [pubsub: opts[:pubsub]], name: opts[:name] || __MODULE__)
  end

  def init(pubsub: pubsub) do
    # FIXME replace ThundermoonWeb.PubSub with :sim, replace topic with :realm
    Logger.info("realm server started")
    {:ok, %{pubsub: pubsub || ThundermoonWeb.PubSub, topic: "Thundermoon.GameOfLife"}}
  end

  def handle_call(:get_root, _from, state) do
    {:reply, Data.get_data(), state}
  end

  def handle_call({:set_root, data}, _from, state) do
    {:reply, set_data(data, state), state}
  end

  def handle_call({:create, factory, config}, _from, state) do
    with data <- factory.create(config),
         :ok <- set_data(data, state) do
      {:reply, :ok, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call({:start_sim, func}, _from, state) do
    with :ok <- GenServer.cast(SimulationLoop, {:start, func}),
         :ok <- Data.set_running(true),
         :ok <- set_running(true, state) do
      {:reply, :ok, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call(:stop_sim, _from, state) do
    with :ok <- GenServer.cast(SimulationLoop, :stop),
         :ok <- Data.set_running(false),
         :ok <- set_running(false, state) do
      {:reply, :ok, state}
    else
      error -> {:reply, error, state}
    end
  end

  def handle_call(:started?, _from, state) do
    {:reply, Data.running?(), state}
  end

  def handle_call({:sim, func}, _from, state) do
    case execute_task(func, state) do
      {:exit, reason} ->
        {:reply, {:error, reason}, state}

      {:ok, data} ->
        {:reply, :ok, state}
    end
  end

  defp execute_task(sim_func, state) when is_function(sim_func) do
    Task.Supervisor.async_nolink(Sim.TaskSupervisor, fn ->
      Data.get_data()
      |> sim_func.()
      |> set_data(state)
    end)
    |> Task.yield()
  end

  defp set_running(value, state) do
    with :ok <- Data.set_running(value),
         :ok <- broadcast(state, {:sim, started: value}) do
      :ok
    else
      error -> error
    end
  end

  defp set_data(data, state) do
    with :ok <- Data.set_data(data),
         :ok <- broadcast(state, {:update, data: data}) do
      :ok
    else
      error -> error
    end
  end

  defp broadcast(state, payload) do
    PubSub.broadcast(state.pubsub, state.topic, payload)
  end

  # def start_link(opts) do
  #   GenServer.start_link(__MODULE__, {opts[:supervisor_module]}, name: opts[:name])
  # end

  # def init({supervisor_module}) do
  #   # we don't create the counter immediately as
  #   # the endpoint pubsub is not started at this point
  #   {:ok, %{root: nil, supervisor_module: supervisor_module}}
  # end

  # def handle_call({:create, root_module, args}, _from, %{root: nil} = state) do
  #   state = Map.merge(state, %{root_module: root_module, create_args: args})
  #   root = create_root(state)
  #   {:reply, {:ok, root.pid}, %{state | root: root}}
  # end

  # def handle_call({:create, _root_module, _args}, _from, %{root: root} = state) do
  #   {:reply, {:ok, root.pid}, state}
  # end

  # def handle_call(:restart_root, _from, %{root: nil} = state) do
  #   {:reply, :ok, state}
  # end

  # def handle_call(:restart_root, _from, state) do
  #   Logger.info("terminate root #{state.root_module}")
  #   :ok = DynamicSupervisor.terminate_child(state.supervisor_module, state.root.pid)
  #   {:reply, :ok, %{state | root: create_root(state)}}
  # end

  # def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
  #   root =
  #     cond do
  #       nil == state.root -> nil
  #       ref == state.root.ref -> create_root(state)
  #       true -> state.root
  #     end

  #   {:noreply, %{state | root: root}}
  # end

  # defp create_root(state) do
  #   Logger.info("create root module #{state.root_module}")

  #   child_spec = %{
  #     id: state.root_module,
  #     start: {state.root_module, :start_link, [state.create_args]}
  #   }

  #   {:ok, pid} = DynamicSupervisor.start_child(state.supervisor_module, child_spec)

  #   ref = Process.monitor(pid)
  #   %{ref: ref, pid: pid}
  # end
end
