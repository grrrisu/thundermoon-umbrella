defmodule Sim.Realm.CommandBus do
  @moduledoc """
  The command bus routes the incoming commands to their domain service to execute the command in a separate task.
  Only one command per domain service is executed simultaneously, but different domain services can run at the same time.
  """
  use GenStage
  require Logger

  @type context :: atom
  @type cmd :: atom
  @type command :: {context, cmd, keyword}

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @spec dispatch(atom | pid | {atom, any} | {:via, atom, any}, command) :: any
  def dispatch(server, command) do
    GenStage.cast(server, {:dispatch, command})
  end

  def init(opts) do
    Logger.info("CommandBus started")

    args = [
      partitions: opts[:partitions],
      hash: fn {domain, command} ->
        {command, domain}
      end
    ]

    {:producer, nil, dispatcher: {GenStage.PartitionDispatcher, args}}
  end

  def handle_cast({:dispatch, command}, state) do
    {:noreply, [command], state}
  end

  def handle_demand(demand, state) do
    # we handle events in handle_cast dispatch
    {:noreply, [], state}
  end
end
