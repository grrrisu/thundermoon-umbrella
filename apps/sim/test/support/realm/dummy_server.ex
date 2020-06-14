defmodule Test.Dummy.RealmServer do
  use Sim.Realm.Server, app_module: Test.Dummy

  def sim_func do
    fn ->
      get_data()
      |> count()
      |> set_data()
    end
  end

  defp count(n) when n >= 0 do
    n + 1
  end

  defp count(n) when n < 0 do
    raise "count failed"
  end
end
