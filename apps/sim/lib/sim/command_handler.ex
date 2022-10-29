defmodule Sim.CommandHandler do
  @moduledoc """
  examples

    def execute(:stop) do
      SimulationLoop.stop(GameOfLife.SimulationLoop)
      [{:sim, started: false}]
    end

    def execute(:create, config: size) do
      :ok = Data.set_data(GameOfLife.Data, Grid.create(size))
      [{:update, :ok}]
    end
  """

  @type command :: atom
  @type result :: atom
  @type data :: any
  @type event :: {result, data}

  @doc """
  handle the execution of the command
  this will be executed within a task
  returns a list of events and/or commands
  """
  @callback execute(command, keyword) :: [
              event | {:command, {command, keyword} | {:event, any}}
            ]
end
