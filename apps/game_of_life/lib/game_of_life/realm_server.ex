defmodule GameOfLife.RealmServer do
  use Sim.Realm.Server, app_module: GameOfLife

  alias GameOfLife.Grid

  def handle_call({:toggle, x, y}, _from, state) do
    data =
      get_data()
      |> Grid.toggle(x, y)
      |> set_data()

    {:reply, data, state}
  end

  def handle_call(:clear, _from, state) do
    data =
      get_data()
      |> Grid.clear()
      |> set_data()

    {:reply, data, state}
  end
end
