defmodule Sim.Realm.DoaminServiceTest do
  use ExUnit.Case, async: false

  alias Sim.Realm.DomainService

  def execute(:sim, []), do: [{:sim, :result}]
  def execute(:fail, arg: arg), do: {:error, "fail with #{arg}"}
  def execute(:crash, arg: arg), do: raise("crash #{arg}")

  test "execute events" do
    {:ok, worker_supervisor} = start_supervised(Task.Supervisor)
    events = [{:sim, []}, {:fail, arg: "one"}, {:crash, arg: "command"}]

    [res1, res2, res3] =
      DomainService.execute(events, Sim.Realm.DoaminServiceTest, worker_supervisor)

    assert {:ok, [{:sim, :result}]} = res1
    assert {:ok, {:error, "fail with one"}} = res2
    assert {:exit, {%RuntimeError{message: "crash command"}, _stacktrace}} = res3
  end

  test "filter" do
    results = [
      {:ok, [{:sim, :result}]},
      {:ok, {:error, "fail with one"}},
      {:exit, {%RuntimeError{message: "crash command"}, []}},
      {:exit, {:stopped, ["first"]}},
      {:exit, {:undef, ["{Meeple.Service.Admin, :execute, [:foobar]}"]}},
      {:exit, "unknown error"}
    ]

    [res1, res2, res3, res4, res5, res6] = DomainService.filter(results)
    assert {:sim, :result} = res1
    assert {:error, "fail with one"} = res2
    assert {:error, "crash command"} = res3
    assert {:error, "exited with stopped first"}

    assert {:error,
            "exited with undef {Meeple.Service.Admin, :execute, [:foobar]}, probaly an UndefinedFunctionError"}

    assert {:error, "unknown error: unknow error"}
  end
end
