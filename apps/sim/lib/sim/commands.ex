defmodule Sim.Commands do
  @moduledoc """
  examples

    def handle_command(%{command: :start}) do
      SimulationLoop.start(GameOfLife.SimulationLoop, 1_000, %{command: :sim})
    end

    def handle_command(%{command: :stop}) do
      SimulationLoop.stop(GameOfLife.SimulationLoop)
    end

    def handle_command(%{command: :create, config: config}) do
      Data.set_data(GameOfLife.Data)
      |> Simulation.create(config)
      |> Data.set_data(GameOfLife.Data)
    end

    def handle_command(%{command: :sim}) do
      Data.get_data(GameOfLife.Data)
      |> Simulation.sim()
      |> Data.set_data(GameOfLife.Data)
    end
  """

  @type command :: %{command: term}
  # @type command :: %{atom, keyword}
  @type state :: %{current_lock: term}

  @doc """
  set the lock for the given command
  """
  @callback lock(state, command) :: {:ok, state} | {:locked, state}

  @doc """
  unset the lock for the given command
  """
  @callback unlock(state, command) :: state

  @doc """
  handle the execution of the command
  this will be executed within a task
  """
  @callback handle_command(command) :: :ok | {:error, term}
end
