defmodule Test.CommandHandler do
  use Sim.Commands.Helpers, app_module: Test.Realm
  use Sim.Commands.GlobalLock

  @impl true
  def handle_command(%{command: :create, config: size}) do
    change_data(fn _nil -> size * 2 end)
  end

  @impl true
  def handle_command(%{command: :start, delay: delay}) do
    start_simulation_loop(100)
  end

  @impl true
  def handle_command(%{command: :stop}) do
    stop_simulation_loop()
  end

  @impl true
  def handle_command(%{command: :sim}) do
    change_data(fn n -> n + 1 end)
  end

  @impl true
  def handle_command(%{command: :crash}) do
    change_data(fn n -> raise "crash command" end)
  end

  def handle_command(any) do
    IO.puts("unhandled command #{inspect(any)}")
  end
end
