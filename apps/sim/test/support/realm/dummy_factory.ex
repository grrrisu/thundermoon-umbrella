defmodule Test.Dummy.Factory do
  def create(:raise) do
    raise "create crashed"
  end

  def create(config \\ %{initial: 0}) do
    config.initial
  end
end
