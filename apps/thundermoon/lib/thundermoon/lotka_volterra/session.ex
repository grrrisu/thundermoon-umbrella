defmodule Thundermoon.Session do
  @enforce_keys [:pid, :ref]
  defstruct [:pid, :ref, running: false]
end
