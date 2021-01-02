defmodule Sim.Commands.Helpers do
  defmacro __using__(opts) do
    app_module = opts[:app_module]

    quote do
      alias Sim.Realm
      alias Sim.Realm.{Data, SimulationLoop}

      @data_server Realm.server_name(unquote(app_module), "Data")
      @simulation_loop Realm.server_name(unquote(app_module), "SimulationLoop")

      @behaviour Sim.Commands

      def start_simulation_loop(delay \\ 1_000, command \\ %{command: :sim}) do
        SimulationLoop.start(@simulation_loop, delay, command)
      end

      def stop_simulation_loop() do
        SimulationLoop.stop(@simulation_loop)
      end

      def set_data(data) do
        Data.set_data(@data_server, data)
      end

      def get_data() do
        Data.get_data(@data_server)
      end

      def change_data(change_func) do
        get_data()
        |> change_func.()
        |> set_data()
      end
    end
  end
end
