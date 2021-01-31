defmodule Test.CommandHandler do
  use Sim.Commands.SimHelpers, app_module: Test.Realm
  use Sim.Commands.DataHelpers, app_module: Test.Realm

  @impl true
  def execute({:test, :create, config: size}) do
    change_data(fn _nil -> size * 2 end)
  end

  @impl true
  def execute({:test, :sim_start, delay: delay}) do
    start_simulation_loop(delay, {:test, :sim})
  end

  @impl true
  def execute({:test, :sim_stop, []}) do
    stop_simulation_loop()
  end

  @impl true
  def execute({:test, :sim, []}) do
    change_data(fn n -> n + 1 end)
  end

  def execute({:test, :echo, payload: payload}) do
    [{:test, :echoed, payload: payload}]
  end

  @impl true
  def execute({:test, :crash, []}) do
    change_data(fn _n -> raise "crash command" end)
  end

  def execute(any) do
    IO.puts("unhandled command #{inspect(any)}")
    [{:error, "unhandled command #{inspect(any)}"}]
  end
end
