defmodule Sim.Commands.DataHelpers do
  defmacro __using__(opts) do
    app_module = opts[:app_module]

    quote do
      alias Sim.Realm
      alias Sim.Realm.Data

      @data_server Realm.server_name(unquote(app_module), "Data")

      @behaviour Sim.CommandHandler

      def set_data(set_func) when is_function(set_func) do
        :ok = Data.set_data(@data_server, set_func)
        [{:update, :ok}]
      end

      def set_data(data) do
        Data.set_data(@data_server, data)
        [{:update, data: data}]
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
