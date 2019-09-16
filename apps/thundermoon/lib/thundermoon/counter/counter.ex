defmodule Thundermoon.Counter do
  @moduledoc """
  Context for counter.
  It acts as a single point of entry to the counter.
  """

  alias Thundermoon.CounterRealm

  def create() do
    GenServer.call(CounterRealm, :create)
  end

  def get_root() do
    GenServer.call(CounterRealm, :get_root)
  end

  def get_digits() do
    get_root() |> GenServer.call(:get_digits)
  end

  def inc(digit) do
    get_root() |> GenServer.cast({:inc, digit})
  end

  def dec(digit) do
    get_root() |> GenServer.cast({:dec, digit})
  end

  def reset() do
    get_root() |> GenServer.call(:reset)
  end
end
