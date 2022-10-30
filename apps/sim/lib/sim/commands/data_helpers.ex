defmodule Sim.Commands.DataHelpers do
  defmacro __using__(opts) do
    app_module = opts[:app_module]

    quote do
      alias Sim.Realm
      alias Sim.Realm.Data

      @data_server Realm.server_name(unquote(app_module), "Data")
      def get_data() do
        Data.get_data(@data_server)
      end

      def get_data(get_func) when is_function(get_func) do
        Data.get_data(@data_server, get_func)
      end

      def set_data({data, events}) do
        Data.set_data(@data_server, data)
        events
      end

      def set_data(set_func) when is_function(set_func) do
        :ok = Data.set_data(@data_server, set_func)
        [{:update, :ok}]
      end

      def set_data(data) do
        {data, [{:update, data: data}]}
        |> set_data()
      end

      def update_data(update_func) do
        Data.update(@data_server, update_func)
      end

      # get_data is executed by the Data agent
      # change_func is executed by the caller
      # set_data is executed by the Data agent again
      def change_data(change_func) when is_function(change_func) do
        get_data()
        |> change_func.()
        |> set_data()
      end

      # get_data is executed by the Data agent
      # change_func is executed by the caller
      # update_func is executed by the Data agent again
      def change_data(change_func, update_func)
          when is_function(change_func) and is_function(update_func) do
        with {:ok, changes} <- get_data() |> change_func.() do
          update_data(fn data -> update_func.(data, changes) end)
        else
          error -> error
        end
      end

      # get_func is executed by the Data agent
      # change_func is executed by the caller
      # update_func is executed by the Data agent again
      def change_data(get_func, change_func, update_func)
          when is_function(get_func) and is_function(change_func) and is_function(update_func) do
        with {:ok, changes} <- get_data(get_func) |> change_func.() do
          update_data(fn data -> update_func.(data, changes) end)
        else
          error -> error
        end
      end
    end
  end
end
