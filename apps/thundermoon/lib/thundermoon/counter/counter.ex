defmodule Thundermoon.Counter do
  @moduledoc """
  Context for counter.
  It acts as a single point of entry to the counter.
  """

  alias Thundermoon.CounterRealm

  def create() do
    GenServer.call(CounterRealm, :create)
  end

  def get_counter() do
    GenServer.call(CounterRealm, :get_counter)
  end

  def get_digits() do
    get_counter() |> GenServer.call(:get_digits)
  end

  def inc(digit) do
    get_counter() |> GenServer.cast({:inc, digit})
  end

  def dec(digit) do
    get_counter() |> GenServer.cast({:dec, digit})
  end

  def reset() do
    get_counter() |> GenServer.call(:reset)
  end
end
