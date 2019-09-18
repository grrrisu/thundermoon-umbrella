defmodule Thundermoon.Counter do
  @moduledoc """
  Context for counter.
  It acts as a single point of entry to the counter.
  """

  alias Thundermoon.CounterRealm
  alias Thundermoon.CounterSimulation

  def create() do
    GenServer.call(CounterRealm, :create)
  end

  def start() do
    GenServer.cast(CounterSimulation, :start)
  end

  def stop() do
    GenServer.cast(CounterSimulation, :stop)
  end

  def started?() do
    GenServer.call(CounterSimulation, :started?)
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
