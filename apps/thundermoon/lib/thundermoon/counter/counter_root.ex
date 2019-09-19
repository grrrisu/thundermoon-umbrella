defmodule Thundermoon.CounterRoot do
  @moduledoc """
  This module provides functions to read and change the counter.
  It takes care that only one operation is executed and that
  after a change a read operation will reflect this changes:
  ```
  assert %{digit_1: 0, digit_10: 0, digit_100: 0} = Counter.get_digits()
  Counter.inc(10)
  assert %{digit_1: 0, digit_10: 1, digit_100: 0} = Counter.get_digits()
  ```
  """
  # GenServer is temporary as it will be restarted by the counter realm
  use GenServer, restart: :temporary

  alias Thundermoon.Digit
  alias Thundermoon.DigitSupervisor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, create()}
  end

  def handle_call(:get_digits, _from, state) do
    {:reply, digits_to_map(state), state}
  end

  # need to invoke call (not cast), otherwise the counter has not enough time
  # to terminate and be properly restarted
  def handle_call(:reset, _from, state) do
    {:stop, :normal, nil, state}
  end

  def handle_cast({:inc, digit}, state) do
    execute_action(state, digit, &Digit.inc(&1))
    {:noreply, state}
  end

  def handle_cast({:dec, digit}, state) do
    execute_action(state, digit, &Digit.dec(&1))
    {:noreply, state}
  end

  def terminate(_reason, state) do
    Enum.each(state, fn {_key, digit} ->
      DynamicSupervisor.terminate_child(DigitSupervisor, digit.pid)
    end)
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {crashed_digit, _pid_ref} = find_digit(state, ref)
    new_state = create_digit(state, crashed_digit, 0)

    {:noreply, new_state}
  end

  def handle_info({:overflow, [digit, :inc]}, state) do
    case bigger_digit(digit) do
      {:error, "counter overflow"} ->
        {:stop, :normal, state}

      sibling ->
        inc_digit(state, sibling)
        {:noreply, state}
    end
  end

  def handle_info({:overflow, [_digit, :dec]}, state) do
    {:stop, :normal, state}
  end

  def handle_info(_msg, state) do
    IO.puts("info")
    {:noreply, state}
  end

  defp execute_action(state, number, func) do
    case get_digit(state, number) do
      {:ok, digit} -> func.(digit.pid)
      :error -> nil
    end
  end

  defp bigger_digit(crashed_digit) do
    case crashed_digit do
      :digit_1 -> :digit_10
      :digit_10 -> :digit_100
      :digit_100 -> {:error, "counter overflow"}
    end
  end

  defp inc_digit(state, digit) do
    state
    |> Map.get(digit)
    |> Map.get(:pid)
    |> Digit.inc()
  end

  defp find_digit(state, ref) do
    Enum.find(state, fn digit ->
      digit
      |> elem(1)
      |> Map.get(:ref) == ref
    end)
  end

  defp get_digit(state, number) do
    key = String.to_atom("digit_#{number}")
    Map.fetch(state, key)
  end

  defp digits_to_map(state) do
    %{
      digit_1: Digit.get(state.digit_1.pid),
      digit_10: Digit.get(state.digit_10.pid),
      digit_100: Digit.get(state.digit_100.pid)
    }
  end

  defp create() do
    %{}
    |> create_digit(:digit_1, 0)
    |> create_digit(:digit_10, 0)
    |> create_digit(:digit_100, 0)
  end

  defp create_digit(state, key, value) do
    child = %{id: Digit, start: {Digit, :start, [self(), key, value]}}
    {:ok, pid} = DynamicSupervisor.start_child(DigitSupervisor, child)

    ref = Process.monitor(pid)
    Map.put(state, key, %{pid: pid, ref: ref})
  end
end
