defmodule Test.RealmCommandHandler do
  use Sim.Commands.SimHelpers, app_module: Test.Realm
  use Sim.Commands.DataHelpers, app_module: Test.Realm

  @impl true
  def execute(:create, config: size) do
    change_data(fn _nil -> size * 2 end)
  end

  @impl true
  def execute(:start, delay: delay, command: command) do
    start_simulation_loop(delay, command)
  end

  @impl true
  def execute(:stop, []) do
    stop_simulation_loop()
  end

  def execute(any, _) do
    IO.puts("unhandled realm command #{inspect(any)}")
    [{:error, "unhandled realm command #{inspect(any)}"}]
  end
end
