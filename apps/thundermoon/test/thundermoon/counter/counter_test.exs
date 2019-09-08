defmodule Thundermoon.CounterTest do
  use ExUnit.Case

  alias Thundermoon.Counter

  setup do
    {:ok, counter} = start_supervised({Thundermoon.Counter, name: Thundermoon.Counter})
    %{counter: counter}
  end

  test "get digits" do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits()
  end

  test "restart digit" do
    Counter.inc(10)
    state = :sys.get_state(Thundermoon.Counter)
    Agent.stop(state.digit_10.pid, :shutdown)
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits()
  end

  test "inc digit 10" do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits()
    Counter.inc(10)
    assert %{digit_1: 0, digit_10: 1, digit_100: 0} = Counter.get_digits()
  end

  test "inc digit unknown" do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits()
    Counter.inc("unknown")
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits()
  end

  test "dec digit 10" do
    Counter.inc(10)
    assert %{digit_1: 0, digit_10: 1, digit_100: 0} = Counter.get_digits()
    Counter.dec(10)
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits()
  end
end
