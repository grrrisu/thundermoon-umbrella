defmodule Sim.Realm do
  @moduledoc """
  The context for realm
  """
  alias Sim.Realm.Server

  defmacro __using__(opts) do
    app_name = opts[:name]

    quote do
      @supervisor unquote(app_name)
      @server Server.server_name(unquote(app_name))

      def get_root() do
        GenServer.call(@server, :get_root)
      end

      def set_root(root) do
        GenServer.call(@server, {:set_root, root})
      end

      def create(factory, config) when is_atom(factory) do
        GenServer.call(@server, {:create, factory, config})
      end

      def recreate(factory, config) when is_atom(factory) do
        GenServer.call(@server, :stop_sim)
        GenServer.call(@server, {:create, factory, config})
      end

      def restart() do
        :ok = @supervisor.restart_realm()
      end

      def start_sim(func) do
        GenServer.call(@server, {:start_sim, func})
      end

      def stop_sim() do
        GenServer.call(@server, :stop_sim)
      end

      def started?() do
        GenServer.call(@server, :started?)
      end

      def sim(func) do
        GenServer.cast(@server, {:sim, func})
      end
    end
  end
end
