defmodule Test.CommandHandler do
  use Sim.Commands.Helpers, app_module: Test.Realm
  use Sim.Commands.GlobalLock

  @impl true
  def handle_command({:create, config: size}) do
    change_data(fn _nil -> size * 2 end)
  end

  @impl true
  def handle_command({:sim_start, delay: delay}) do
    start_simulation_loop(delay)
  end

  @impl true
  def handle_command({:sim_stop}) do
    stop_simulation_loop()
  end

  @impl true
  def handle_command({:sim}) do
    change_data(fn n -> n + 1 end)
  end

  @impl true
  def handle_command({:crash}) do
    change_data(fn n -> raise "crash command" end)
  end

  def handle_command(any) do
    IO.puts("unhandled command #{inspect(any)}")
  end
end
