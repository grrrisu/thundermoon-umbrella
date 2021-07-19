defmodule Sim.Integer do
  use Ecto.Type

  @doc """
  An ecto type for integers that are simulated.
  The simulation uses floats to also track small changes, but all other just see an integer.

  type - should output the name of the db type
  cast - should receive any type and output your custom Ecto type
  load - should receive the db type and output your custom Ecto type
  dump - should receive your custom Ecto type and output the db type
  """

  @impl true
  def type, do: :float

  @impl true
  def cast(nil), do: {:ok, 0}

  @impl true
  def cast(value) when is_float(value), do: {:ok, trunc(value)}

  @impl true
  def cast(value) when is_integer(value), do: {:ok, value}

  @impl true
  def cast(value) when is_binary(value) do
    {value, _} = Integer.parse(value)
    {:ok, value}
  end

  @impl true
  def load(value) do
    {:ok, trunc(value)}
  end

  @impl true
  def dump(value) when is_integer(value), do: {:ok, value / 1}

  @impl true
  def dump(_value), do: :error
end
