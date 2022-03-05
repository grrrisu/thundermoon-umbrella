defmodule Sim.Commands.SimHelpers do
  defmacro __using__(opts) do
    app_module = opts[:app_module]

    quote do
      alias Sim.Realm
      alias Sim.Realm.SimulationLoop

      @simulation_loop Realm.server_name(unquote(app_module), "SimulationLoop")
      @realm unquote(app_module)

      def start_simulation_loop(delay) do
        start_simulation_loop(delay, {:sim, :tick})
      end

      def start_simulation_loop(delay, tick_function) when is_function(tick_function) do
        SimulationLoop.start(@simulation_loop, delay, tick_function)
        [{:sim, started: true}]
      end

      def start_simulation_loop(delay, command) when is_tuple(command) do
        start_simulation_loop(delay, fn -> @realm.send_command(command) end)
      end

      def stop_simulation_loop() do
        SimulationLoop.stop(@simulation_loop)
        [{:sim, started: false}]
      end
    end
  end
end
