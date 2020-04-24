defmodule Thundermoon.DigitTest do
  use ExUnit.Case, async: true

  alias Phoenix.PubSub

  alias Thundermoon.Digit

  setup do
    {:ok, digit_0} = Digit.start(self(), :digit_10, 0)
    {:ok, digit_9} = Digit.start(self(), :digit_10, 9)
    PubSub.subscribe(ThundermoonWeb.PubSub, "counter")

    on_exit(fn ->
      :ok = Agent.stop(digit_0)
      :ok = Agent.stop(digit_9)
      PubSub.unsubscribe(ThundermoonWeb.PubSub, "counter")
    end)

    %{digit_0: digit_0, digit_9: digit_9}
  end

  defp assert_broadcast_value(value) do
    assert_received %Phoenix.Socket.Broadcast{
      event: "update",
      payload: %{digit_10: ^value},
      topic: "counter"
    }
  end

  test "start with value 5" do
    assert {:ok, digit} = Digit.start(nil, :digit_10, 5)
    assert Digit.get(digit) == 5
    assert_broadcast_value(5)
    assert :ok = Agent.stop(digit)
  end

  test "inc by 1", %{digit_0: digit} do
    assert Digit.get(digit) == 0
    assert :ok = Digit.inc(digit)
    assert Digit.get(digit) == 1
    assert_broadcast_value(1)
  end

  test "dec by 1", %{digit_9: digit} do
    assert Digit.get(digit) == 9
    assert :ok = Digit.dec(digit)
    assert Digit.get(digit) == 8
    assert_broadcast_value(8)
  end

  test "inc overflow", %{digit_9: digit} do
    assert Digit.get(digit) == 9
    assert :ok = Digit.inc(digit)
    assert_received {:overflow, [:digit_10, :inc]}
    assert_broadcast_value(0)
    assert Digit.get(digit) == 0
  end

  test "dec overflow", %{digit_0: digit} do
    assert Digit.get(digit) == 0
    assert :ok = Digit.dec(digit)
    assert_received {:overflow, [:digit_10, :dec]}
    assert_broadcast_value(9)
    assert Digit.get(digit) == 9
  end
end
