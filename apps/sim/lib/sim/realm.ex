defmodule Sim.Realm do
  @moduledoc """
  The context for realm
  """
  alias Sim.Realm.CommandBus

  def server_name(name, server) do
    Module.concat(name, server)
  end

  defmacro __using__(opts) do
    app_module = opts[:app_module]
    context = opts[:context] || :realm

    quote do
      alias Sim.Realm
      alias Sim.Realm.{Data, SimulationLoop}

      @supervisor Realm.server_name(unquote(app_module), "Supervisor")
      @server Realm.server_name(unquote(app_module), "CommandBus")
      @simulation_loop Realm.server_name(unquote(app_module), "SimulationLoop")
      @data Realm.server_name(unquote(app_module), "Data")
      @context unquote(context)

      def get_root() do
        Data.get_data(@data)
      end

      def send_command(command) do
        CommandBus.dispatch(@server, command)
      end

      def create(config) do
        send_command({@context, :create, config: config})
      end

      def recreate(config) do
        stop_sim()
        create(config)
      end

      def restart() do
        Supervisor.stop(@supervisor)
      end

      def start_sim(delay \\ 1_000, command \\ {:sim}) do
        send_command({@context, :sim_start, delay: delay})
      end

      def stop_sim() do
        send_command({@context, :sim_stop})
      end

      def started?() do
        SimulationLoop.running?(@simulation_loop)
      end
    end
  end
end
