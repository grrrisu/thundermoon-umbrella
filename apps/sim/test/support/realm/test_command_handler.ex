defmodule Test.CommandHandler do
  use Sim.Commands.SimHelpers, app_module: Test.Realm
  use Sim.Commands.DataHelpers, app_module: Test.Realm

  @impl true
  def execute({:create, config: size}) do
    change_data(fn _nil -> size * 2 end)
  end

  @impl true
  def execute({:sim_start, delay: delay}) do
    start_simulation_loop(delay)
  end

  @impl true
  def execute({:sim_stop}) do
    stop_simulation_loop()
  end

  @impl true
  def execute({:sim}) do
    change_data(fn n -> n + 1 end)
  end

  @impl true
  def execute({:crash}) do
    change_data(fn _n -> raise "crash command" end)
  end

  def execute(any) do
    IO.puts("unhandled command #{inspect(any)}")
    [{:error, "unhandled command #{inspect(any)}"}]
  end
end
