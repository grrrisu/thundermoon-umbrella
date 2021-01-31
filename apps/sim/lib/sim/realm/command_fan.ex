defmodule Sim.Realm.CommandFan do
  @moduledoc """
  A command bus routing commands to a domain service executing the command in a separate task.
  One command per domain service can be executed, but multiple commands from different
  domain services can run at the same time.
  """
  use GenServer

  require Logger

  alias Sim.Realm.EventBus

  @type context :: atom
  @type cmd :: atom
  @type command :: {context, cmd, keyword}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl true
  def init(opts) do
    {:ok,
     %{
       services: init_services(opts[:services]),
       task_supervisor_module: opts[:task_supervisor_module],
       event_bus_module: opts[:event_bus_module]
     }}
  end

  def init_services(services) do
    services
    |> Enum.reduce(%{}, fn {service, module}, acc ->
      value = %{module: module, running_command: nil, running_ref: nil, queue: :queue.new()}
      Map.put_new(acc, service, value)
    end)
  end

  @spec dispatch(atom | pid | {atom, any} | {:via, atom, any}, command) :: any
  def dispatch(server, command) do
    GenServer.call(server, {:dispatch, command})
  end

  def handle_call({:dispatch, {context, cmd}}, from, state) do
    handle_call({:dispatch, {context, cmd, []}}, from, state)
  end

  @impl true
  def handle_call({:dispatch, {context, _, _} = command}, _from, state) do
    case Map.fetch(state.services, context) do
      :error ->
        {:reply, {:error, "no service found for #{context}"}, state}

      {:ok, service} ->
        {:reply, :ok, assign_service(state, context, queue_or_execute(command, service, state))}
    end
  end

  # The task completed successfully
  @impl true
  def handle_info({ref, :ok}, state) do
    case find_ended_task(ref, state.services) do
      nil ->
        noreply_unknown_ref(ref, "received answer :ok}", state)

      {context, service} ->
        # We don't care about the DOWN message now, so let's demonitor and flush it
        Process.demonitor(ref, [:flush])

        Logger.debug(
          "task executing command #{inspect(service.running_command)} finished successfully"
        )

        {:noreply, assign_service(state, context, handle_answer(service, state))}
    end
  end

  # The task failed
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    case find_ended_task(ref, state.services) do
      nil ->
        noreply_unknown_ref(ref, "received DOWN", state)

      {context, service} ->
        Logger.debug(
          "task executing command #{inspect(service.running_command)} failed with reason #{
            inspect(reason)
          }"
        )

        handle_task_error(service.running_command, reason, state.event_bus_module)
        {:noreply, assign_service(state, context, handle_answer(service, state))}
    end
  end

  @spec queue_or_execute(command, map, map) :: map
  def queue_or_execute(command, %{module: module, running_command: nil} = service_state, state) do
    task =
      Task.Supervisor.async_nolink(
        state.task_supervisor_module,
        fn ->
          module.execute(command)
          |> store_events(state.event_bus_module)
        end
      )

    %{service_state | running_command: command, running_ref: task.ref}
  end

  @spec queue_or_execute(command, map, map) :: map
  def queue_or_execute(command, %{queue: queue} = service_state, _state) do
    %{service_state | queue: :queue.in(command, queue)}
  end

  def store_events(events, event_bus_module) do
    EventBus.add_events(event_bus_module, events)
  end

  defp find_ended_task(ref, services) do
    Enum.find(services, fn {_context, service} ->
      service.running_ref == ref
    end)
  end

  defp handle_task_error(running_command, reason, event_bus_module) do
    # add_command({:sim_stop})
    events = [{:command_failed, command: running_command, reason: reason}]
    store_events(events, event_bus_module)
  end

  defp handle_answer(service, state) do
    service = %{service | running_ref: nil, running_command: nil}

    case :queue.out(service.queue) do
      {{:value, command}, queue} -> queue_or_execute(command, %{service | queue: queue}, state)
      {:empty, _queue} -> service
    end
  end

  defp noreply_unknown_ref(ref, message, state) do
    Logger.warn("#{message} from unkown ref #{inspect(ref)}")
    {:noreply, state}
  end

  defp assign_service(state, context, service) do
    put_in(state, [:services, context], service)
  end
end
