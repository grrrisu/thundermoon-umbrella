defmodule Thundermoon.CounterTest do
  use ExUnit.Case

  alias Thundermoon.Counter

  setup do
    {:ok, counter} = start_supervised(Thundermoon.Counter)
    %{counter: counter}
  end

  test "get digits", %{counter: pid} do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits(pid)
  end

  test "restart digit", %{counter: pid} do
    Counter.inc(pid, 10)
    state = :sys.get_state(pid)
    Agent.stop(state.digit_10.pid, :shutdown)
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits(pid)
  end

  test "inc digit 10", %{counter: pid} do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits(pid)
    Counter.inc(pid, 10)
    assert %{digit_1: 0, digit_10: 1, digit_100: 0} = Counter.get_digits(pid)
  end

  test "inc digit unknown", %{counter: pid} do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits(pid)
    Counter.inc(pid, "unknown")
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits(pid)
  end

  test "dec digit 10", %{counter: pid} do
    Counter.inc(pid, 10)
    assert %{digit_1: 0, digit_10: 1, digit_100: 0} = Counter.get_digits(pid)
    Counter.dec(pid, 10)
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits(pid)
  end
end
