defmodule Test.Dummy.Factory do
  def create(config \\ %{initial: 0})

  def create(:raise) do
    raise "create crashed"
  end

  def create(config) do
    config.initial
  end
end
