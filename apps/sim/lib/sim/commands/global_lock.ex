defmodule Sim.Commands.GlobalLock do
  defmacro __using__(_opts) do
    quote do
      def lock(state, _command) do
        case state.current_lock do
          true -> {:locked, state}
          nil -> {:ok, %{state | current_lock: true}}
        end
      end

      def unlock(state, _command) do
        %{state | current_lock: nil}
      end
    end
  end
end
