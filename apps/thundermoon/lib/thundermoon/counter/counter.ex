defmodule Thundermoon.Counter do
  use GenServer

  alias Thundermoon.Digit
  alias Thundermoon.DigitSupervisor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_digits() do
    GenServer.call(__MODULE__, :get_digits)
  end

  def inc(digit) do
    GenServer.cast(__MODULE__, {:inc, digit})
  end

  def dec(digit) do
    GenServer.cast(__MODULE__, {:dec, digit})
  end

  def init(:ok) do
    state =
      %{}
      |> create_digit(:digit_1, 0)
      |> create_digit(:digit_10, 0)
      |> create_digit(:digit_100, 0)

    {:ok, state}
  end

  def handle_call(:get_digits, _from, state) do
    digits = %{
      digit_1: Digit.get(state.digit_1.pid),
      digit_10: Digit.get(state.digit_10.pid),
      digit_100: Digit.get(state.digit_100.pid)
    }

    {:reply, digits, state}
  end

  def handle_cast({:inc, digit}, state) do
    state
    |> get_digit(digit)
    |> Digit.inc()

    {:noreply, state}
  end

  def handle_cast({:dec, digit}, state) do
    state
    |> get_digit(digit)
    |> Digit.dec()

    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {crashed_digit, _pid_ref} = find_digit(state, ref)
    new_state = create_digit(state, crashed_digit, 0)

    {:noreply, new_state}
  end

  def handle_info(msg, state) do
    IO.puts("info")
    IO.inspect(msg)
    {:noreply, state}
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
    Map.get(state, key).pid
  end

  defp create_digit(state, key, value) do
    child = %{id: Digit, start: {Digit, :start, [value]}}
    {:ok, pid} = DynamicSupervisor.start_child(DigitSupervisor, child)

    ref = Process.monitor(pid)
    Map.put(state, key, %{pid: pid, ref: ref})
  end
end
