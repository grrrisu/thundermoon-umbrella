defmodule Thundermoon.Counter do
  use GenServer

  alias Thundermoon.Digit

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    digit_1 = create_digit()
    digit_10 = create_digit()
    digit_100 = create_digit()
    {:ok, %{digit_1: digit_1, digit_10: digit_10, digit_100: digit_100}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {crashed_digit, _pid_ref} =
      Enum.find(state, fn digit ->
        digit |> elem(1) |> Map.get(:ref) == ref
      end)

    IO.inspect(crashed_digit)

    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end

  defp create_digit() do
    {:ok, pid} = Digit.start()
    ref = Process.monitor(pid)
    %{pid: pid, ref: ref}
  end
end
