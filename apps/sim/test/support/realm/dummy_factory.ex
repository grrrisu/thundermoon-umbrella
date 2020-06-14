defmodule Test.Dummy.Factory do
  def create(config \\ %{initial: 0}) do
    config.initial
  end
end
