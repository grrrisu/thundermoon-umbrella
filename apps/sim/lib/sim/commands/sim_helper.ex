defmodule Sim.Commands.SimHelpers do
  defmacro __using__(opts) do
    app_module = opts[:app_module]

    quote do
      alias Sim.Realm
      alias Sim.Realm.SimulationLoop

      @simulation_loop Realm.server_name(unquote(app_module), "SimulationLoop")

      @behaviour Sim.CommandHandler

      def start_simulation_loop(delay \\ 1_000, command \\ {:sim, :tick}) do
        SimulationLoop.start(@simulation_loop, delay, command)
        [{:sim, started: true}]
      end

      def stop_simulation_loop() do
        SimulationLoop.stop(@simulation_loop)
        [{:sim, started: false}]
      end
    end
  end
end
