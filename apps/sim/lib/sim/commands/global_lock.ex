defmodule Sim.Commands.GlobalLock do
  defmacro __using__(_opts) do
    quote do
      @doc """
      returns only the new lock
      """
      @spec lock(%{current_lock: term}, term) :: {:ok, term} | {:locked, term}
      def lock(state, _command) do
        case state.current_lock do
          true -> {:locked, true}
          nil -> {:ok, true}
          _ -> raise("unexpected lock state #{inspect(state.current_lock)}")
        end
      end

      @doc """
      returns the new state with the new lock
      """
      def unlock(state, _command) do
        %{state | current_lock: nil}
      end
    end
  end
end
