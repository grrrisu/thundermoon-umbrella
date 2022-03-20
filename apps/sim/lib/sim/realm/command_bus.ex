defmodule Sim.Realm.CommandBus do
  @moduledoc """
  The command bus routes the incoming commands to their domain service to execute the command in a separate task.
  You can configure how many events are executed in parallel by setting max_demand and then passing accordingly batch of events.
  At the moment this is one as dispatch only excepts one event.
  """
  use GenStage
  require Logger

  @type context :: atom
  @type cmd :: atom
  @type command :: {context, cmd, keyword}

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @spec dispatch(atom | pid | {atom, any} | {:via, atom, any}, command) :: :ok
  def dispatch(server, command) do
    :ok = GenStage.cast(server, {:dispatch, command})
  end

  def init(opts) do
    Logger.debug("CommandBus started")

    args = [
      partitions: opts[:partitions],
      hash: & &1
    ]

    {:producer, nil, dispatcher: {GenStage.PartitionDispatcher, args}}
  end

  def handle_cast({:dispatch, command}, state) do
    {:noreply, [normalize_command(command)], state}
  end

  def handle_demand(_demand, state) do
    # we handle events in handle_cast dispatch
    {:noreply, [], state}
  end

  defp normalize_command({domain, command}), do: {{command, []}, domain}
  defp normalize_command({domain, command, args}), do: {{command, args}, domain}
end
