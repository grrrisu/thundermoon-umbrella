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
    {:ok, create()}
  end

  def handle_call(:get_digits, _from, state) do
    {:reply, digits_to_map(state), state}
  end

  def handle_cast({:inc, digit}, state) do
    execute_action(state, digit, &Digit.inc(&1))
    {:noreply, state}
  end

  def handle_cast({:dec, digit}, state) do
    execute_action(state, digit, &Digit.dec(&1))

    {:noreply, state}
  end

  defp execute_action(state, digit, func) do
    # execute in its own process to not crash as well if it fails
    spawn(fn ->
      state
      |> get_digit(digit)
      |> func.()
    end)
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    IO.inspect(reason)
    {crashed_digit, _pid_ref} = find_digit(state, ref)
    new_state = create_digit(state, crashed_digit, 0)

    {:noreply, new_state}
  end

  def handle_info({:overflow, [digit, :inc]}, state) do
    state
    |> Map.get(bigger_digit(digit))
    |> Map.get(:pid)
    |> Digit.inc()

    {:noreply, state}
  end

  def handle_info({:overflow, [_digit, :dec]}, state) do
    raise "counter overflow"

    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts("info")
    IO.inspect(msg)
    {:noreply, state}
  end

  defp bigger_digit(crashed_digit) do
    case crashed_digit do
      :digit_1 -> :digit_10
      :digit_10 -> :digit_100
      :digit_100 -> raise "counter overflow"
    end
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
