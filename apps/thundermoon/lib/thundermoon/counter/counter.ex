defmodule Thundermoon.Counter do
  @moduledoc """
  Context for counter.
  It acts as a single point of entry to the counter.
  """
  require Logger

  alias Thundermoon.CounterRealm
  alias Thundermoon.CounterSimulation

  def create() do
    GenServer.call(CounterRealm, :create)
  end

  def start() do
    Logger.info("start counter")
    GenServer.cast(CounterSimulation, :start)
  end

  def stop() do
    Logger.info("stop counter")
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
    Logger.info("inc #{digit} counter")
    get_root() |> GenServer.cast({:inc, digit})
  end

  def dec(digit) do
    Logger.info("dec #{digit} counter")
    get_root() |> GenServer.cast({:dec, digit})
  end

  def reset() do
    Logger.info("reset counter")
    get_root() |> GenServer.call(:reset)
  end
end
