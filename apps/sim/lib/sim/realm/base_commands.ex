defmodule Sim.Realm.BaseCommands do
  @behaviour Sim.Realm.Commands

  def lock(state, _command) do
    case state.current_lock do
      true -> {:locked, state}
      false -> {:ok, %{state | current_lock: true}}
    end
  end

  def unlock(state, _command) do
    %{state | current_lock: false}
  end

  def handle_command(%{command: :start}) do
    Timer.start()
  end

  def handle_command(%{command: :stop}) do
    Timer.stop()
  end

  def handle_command(%{command: :create}) do
  end
end
