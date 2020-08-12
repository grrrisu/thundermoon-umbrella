defmodule LotkaVolterra.RealmServer do
  use Sim.Realm.Server, app_module: LotkaVolterra

  # alias GameOfLife.{Grid, Simulation}

  def sim_func, do: nil
  # # @impl true
  # def sim_func do
  #   fn ->
  #     get_data()
  #     |> Simulation.sim()
  #     |> set_data()
  #   end
  # end

  # def handle_call(:recreate, _from, state) do
  #   current = get_data()

  #   data =
  #     Grid.create(%{size: Grid.height(current)})
  #     |> set_data()

  #   {:reply, data, state}
  # end

  # def handle_call({:toggle, x, y}, _from, state) do
  #   data =
  #     get_data()
  #     |> Grid.toggle(x, y)
  #     |> set_data()

  #   {:reply, data, state}
  # end

  # def handle_call(:clear, _from, state) do
  #   data =
  #     get_data()
  #     |> Grid.clear()
  #     |> set_data()

  #   {:reply, data, state}
  # end
end
