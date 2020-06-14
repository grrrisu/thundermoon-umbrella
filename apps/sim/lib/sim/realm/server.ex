defmodule Sim.Realm.Server do
  @moduledoc """
  This acts as a global lock against the data
  """

  def server_name(name) do
    Module.concat(name, "RealmServer")
  end

  defmacro __using__(opts) do
    app_module = opts[:app_module]

    quote do
      use GenServer

      alias Sim.Realm.{Data, SimulationLoop, Server}

      require Logger

      @data_server Data.agent_name(unquote(app_module))
      @simulation_loop SimulationLoop.server_name(unquote(app_module))
      @task_supervisor Module.concat(unquote(app_module), "TaskSupervisor")

      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok,
          name: (opts[:name] && Server.server_name(opts[:name])) || __MODULE__
        )
      end

      def init(:ok) do
        Logger.debug("start realm server")
        {:ok, %{}, {:continue, :register_to_simulation_loop}}
      end

      def handle_continue(:register_to_simulation_loop, state) do
        register_realm_server()
        {:noreply, state}
      end

      def handle_call(:get_root, _from, state) do
        {:reply, get_data(), state}
      end

      def handle_call({:set_root, data}, _from, state) do
        {:reply, set_data(data), state}
      end

      def handle_call({:create, factory, config}, _from, state) do
        with data <- factory.create(config),
             :ok <- set_data(data) do
          {:reply, data, state}
        else
          error -> {:reply, error, state}
        end
      end

      def handle_call(:start_sim, _from, state) do
        :ok = send_start(sim_func())
        {:reply, :ok, state}
      end

      def handle_call(:stop_sim, _from, state) do
        :ok = send_stop()
        {:reply, :ok, state}
      end

      def handle_call(:started?, _from, state) do
        {:reply, running?(), state}
      end

      def handle_cast({:sim, func}, state) do
        result =
          case execute_task(func, state) do
            {:ok, _} -> :ok
            {:exit, reason} -> {:error, reason}
            nil -> {:error, :timeout}
          end

        send_sim_result(result)
        {:noreply, state}
      end

      defp execute_task(func, state) when is_function(func) do
        Task.Supervisor.async_nolink(
          @task_supervisor,
          fn -> func.() end
        )
        |> Task.yield()
      end

      defp get_data() do
        Data.get_data(@data_server)
      end

      defp set_data(data) do
        :ok = Data.set_data(@data_server, data)
        data
      end

      defp set_running(value) do
        Data.set_running(@data_server, value)
      end

      defp running?() do
        Data.running?(@data_server)
      end

      defp send_start(func) do
        SimulationLoop.start(@simulation_loop, func)
      end

      defp send_stop() do
        SimulationLoop.stop(@simulation_loop)
      end

      defp register_realm_server() do
        SimulationLoop.register_realm_server(@simulation_loop)
      end

      defp send_sim_result(result) do
        SimulationLoop.send_sim_result(@simulation_loop, result)
      end
    end
  end
end
