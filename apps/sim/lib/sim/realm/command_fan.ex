defmodule Sim.Realm.CommandFan do
  @moduledoc """
  A command bus routing commands to a domain service executing the command in a separate task.
  One command per domain service can be executed, but multiple commands from different
  domain services can run at the same time.
  """
  use GenServer

  require Logger

  @type command :: {atom, atom, keyword}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:services], name: opts[:name])
  end

  @impl true
  def init(services) do
    {:ok, init_services(services)}
  end

  def init_services(services) do
    services
    |> Enum.reduce(%{}, fn {service, module}, acc ->
      value = %{module: module, running_command: nil, queue: :queue.new()}
      Map.put_new(acc, service, value)
    end)
  end

  @spec dispatch(atom | pid | {atom, any} | {:via, atom, any}, command) :: any
  def dispatch(server, command) do
    GenServer.call(server, {:dispatch, command})
  end

  @impl true
  def handle_call({:dispatch, {context, _, _}} = command, _from, state) do
    case Map.fetch(state, context) do
      :error -> {:reply, {:error, "no service found for #{context}"}, state}
      service -> {:reply, :ok, %{state | context => queue_or_execute(command, service)}}
    end
  end

  @spec queue_or_execute(command, map) :: map
  def queue_or_execute(command, %{module: module, running_task: nil} = service_state) do
    task =
      Task.Supervisor.async_nolink(
        __MODULE__,
        fn ->
          module.execute(command)
        end
      )

    %{service_state | running_task: task.ref}
  end

  @spec queue_or_execute(command, map) :: map
  def queue_or_execute(command, %{queue: queue} = service_state) do
    %{service_state | queue: :queue.in(command, queue)}
  end
end
