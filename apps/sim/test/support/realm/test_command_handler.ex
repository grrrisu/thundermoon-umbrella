defmodule Test.CommandHandler do
  use Sim.Commands.SimHelpers, app_module: Test.Realm
  use Sim.Commands.DataHelpers, app_module: Test.Realm

  @impl true
  def execute(:echo, payload: payload) do
    [{:test, :echoed, payload: payload}]
  end

  @impl true
  def execute(:crash, []) do
    change_data(fn _n -> raise "crash command" end)
  end

  @impl true
  def execute(:tick, []) do
    change_data(fn n -> n + 1 end)
  end

  def execute(any, _) do
    IO.puts("unhandled test command #{inspect(any)}")
    [{:error, "unhandled test command #{inspect(any)}"}]
  end
end
