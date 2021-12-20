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

    quote do
      alias Sim.Realm
      alias Sim.Realm.{Data, SimulationLoop}

      @supervisor Realm.server_name(unquote(app_module), "Supervisor")
      @server Realm.server_name(unquote(app_module), "CommandBus")
      @simulation_loop Realm.server_name(unquote(app_module), "SimulationLoop")
      @data Realm.server_name(unquote(app_module), "Data")

      def get_root() do
        Data.get_data(@data)
      end

      def send_command(command) do
        CommandBus.dispatch(@server, command)
      end

      def create(config) do
        send_command({:user, :create, config: config})
      end

      def recreate(config) do
        stop_sim()
        create(config)
      end

      def restart() do
        Supervisor.stop(@supervisor)
      end

      def start_sim(delay, command) do
        send_command({:user, :start, delay: delay, command: command})
      end

      def stop_sim() do
        send_command({:user, :stop})
      end

      def started?() do
        SimulationLoop.running?(@simulation_loop)
      end
    end
  end
end
