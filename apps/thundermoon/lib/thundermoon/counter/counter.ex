defmodule Thundermoon.Counter do
  use GenServer

  alias Thundermoon.Digit
  alias Thundermoon.DigitSupervisor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    state =
      %{}
      |> create_digit(:digit_1, 0)
      |> create_digit(:digit_10, 0)
      |> create_digit(:digit_100, 0)

    {:ok, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {crashed_digit, _pid_ref} = find_digit(state, ref)
    new_state = create_digit(state, crashed_digit, 0)

    {:noreply, new_state}
  end

  def handle_info(msg, state) do
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

  defp create_digit(state, key, value) do
    child = %{id: Digit, start: {Digit, :start, [value]}}
    {:ok, pid} = DynamicSupervisor.start_child(DigitSupervisor, child)

    ref = Process.monitor(pid)
    Map.put(state, key, %{pid: pid, ref: ref})
  end
end
