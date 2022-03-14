defmodule Sim.Realm.DoaminServiceTest do
  use ExUnit.Case, async: false

  alias Sim.Realm.DomainService

  def execute(:sim, []), do: [{:sim, :result}, {:data, :updated}]
  def execute(:fail, arg: arg), do: {:error, "fail with #{arg}"}
  def execute(:crash, arg: arg), do: raise("crash #{arg}")

  test "execute commands" do
    {:ok, worker_supervisor} = start_supervised(Task.Supervisor)
    commands = [{:sim, []}, {:fail, arg: "one"}, {:crash, arg: "command"}]

    [res1, res2, res3] =
      DomainService.execute(commands, Sim.Realm.DoaminServiceTest, worker_supervisor)

    assert {:ok, [{:sim, :result}, {:data, :updated}]} = res1
    assert {:ok, {:error, "fail with one"}} = res2
    assert {:exit, {%RuntimeError{message: "crash command"}, _stacktrace}} = res3
  end

  test "filter" do
    results = [
      {:ok, [{:sim, :result}]},
      {:ok, [{:sim, :result}, {:data, :updated}]},
      {:ok, {:error, "fail with one"}},
      {:exit, {%RuntimeError{message: "crash command"}, []}},
      {:exit, {:stopped, ["first"]}},
      {:exit, {:undef, ["{Meeple.Service.Admin, :execute, [:foobar]}"]}},
      {:exit, {:noprocess, {"no process running"}}},
      {:exit, "unknown error"}
    ]

    [res1, res2, res3, res4, res5, res6, res7, res8] = DomainService.filter(results)
    assert [{:sim, :result}] == res1
    assert [{:sim, :result}, {:data, :updated}] == res2
    assert {:error, "fail with one"} == res3
    assert {:error, "crash command"} == res4
    assert {:error, "exited with stopped \"first\""} == res5

    assert {:error,
            "exited with undef \"{Meeple.Service.Admin, :execute, [:foobar]}\", probably an UndefinedFunctionError"} ==
             res6

    assert {:error, "exited with noprocess {\"no process running\"}"} == res7

    assert {:error, "unknown error: \"unknown error\""} == res8
  end
end
