defmodule Sim.CommandHandler do
  @moduledoc """
  examples

    def handle_command({:start}) do
      SimulationLoop.start(GameOfLife.SimulationLoop, 1_000, {:sim})
      [{:sim, started: true}]
    end
  """

  @type context :: atom
  @type cmd :: atom
  @type command :: {context, cmd, keyword}
  @type event :: {atom, keyword}

  @doc """
  handle the execution of the command
  this will be executed within a task
  returns a list of events
  """
  @callback execute(command) :: [event]
end
