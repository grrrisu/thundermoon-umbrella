defmodule Sim.Realm.Commands do
  @type command :: %{command: term}
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
