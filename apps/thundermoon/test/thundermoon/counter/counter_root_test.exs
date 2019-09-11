defmodule Thundermoon.CounterRootTest do
  use ExUnit.Case

  alias Thundermoon.CounterRoot

  setup do
    {:ok, counter} = start_supervised(CounterRoot)
    %{counter: counter}
  end

  test "get digits", %{counter: pid} do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = GenServer.call(pid, :get_digits)
  end

  test "restart digit", %{counter: pid} do
    GenServer.cast(pid, {:inc, 10})
    state = :sys.get_state(pid)
    Agent.stop(state.digit_10.pid, :shutdown)
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = GenServer.call(pid, :get_digits)
  end

  test "inc digit 10", %{counter: pid} do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = GenServer.call(pid, :get_digits)
    GenServer.cast(pid, {:inc, 10})
    assert %{digit_1: 0, digit_10: 1, digit_100: 0} = GenServer.call(pid, :get_digits)
  end

  test "inc digit unknown", %{counter: pid} do
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = GenServer.call(pid, :get_digits)
    GenServer.cast(pid, {:inc, "unknown"})
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = GenServer.call(pid, :get_digits)
  end

  test "dec digit 10", %{counter: pid} do
    GenServer.cast(pid, {:inc, 10})
    assert %{digit_1: 0, digit_10: 1, digit_100: 0} = GenServer.call(pid, :get_digits)
    GenServer.cast(pid, {:dec, 10})
    assert %{digit_1: 0, digit_10: 0, digit_100: 0} = GenServer.call(pid, :get_digits)
  end
end
