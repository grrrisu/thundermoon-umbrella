defmodule Sim.Realm.CommandBus do
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
     opts[:services]
     |> init_services()
     |> Map.put_new(:task_supervisor_module, opts[:task_supervisor_module])
     |> Map.put_new(:event_bus_module, opts[:event_bus_module])}
  end

  def init_services(services) do
    %{
      services: init_service_mapping(services),
      workers: init_worker_groups(services)
    }
  end

  defp init_service_mapping(services) do
    services
    |> Enum.reduce(%{}, fn service, acc -> Map.merge(acc, service) end)
  end

  defp init_worker_groups(services) do
    services
    |> Enum.map(fn group ->
      %{
        services: Map.keys(group),
        running_command: nil,
        running_ref: nil,
        queue: :queue.new()
      }
    end)
  end

  def assemble_worker_state(context, state) do
    case Enum.find(state.workers, &Enum.member?(&1.services, context)) do
      nil ->
        {:error, "service #{context} not found"}

      service ->
        service
        |> Map.put(:module, Map.get(state.services, context))
        |> Map.put(:task_supervisor_module, state.task_supervisor_module)
        |> Map.put(:event_bus_module, state.event_bus_module)
    end
  end

  defp update_worker(worker, %{workers: workers} = state) do
    index = Enum.find_index(workers, &(&1.services == worker.services))

    %{
      state
      | workers:
          List.update_at(
            workers,
            index,
            &Map.merge(&1, %{
              running_command: worker.running_command,
              running_ref: worker.running_ref,
              queue: worker.queue
            })
          )
    }
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
    case assemble_worker_state(context, state) do
      {:error, msg} ->
        {:reply, {:error, msg}, state}

      service ->
        {:reply, :ok,
         service
         |> queue_or_execute(command)
         |> update_worker(state)}
    end
  end

  # The task completed successfully
  @impl true
  def handle_info({ref, :ok}, state) do
    case find_ended_task(ref, state) do
      nil ->
        noreply_unknown_ref(ref, "received answer :ok}", state)

      %{running_command: {context, _, _} = running_command} ->
        # We don't care about the DOWN message now, so let's demonitor and flush it
        Process.demonitor(ref, [:flush])

        Logger.debug(
          "task executing command #{inspect(running_command)} finished successfully"
        )

        {:noreply,
         context
         |> assemble_worker_state(state)
         |> handle_answer()
         |> update_worker(state)}
    end
  end

  # The task failed
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    case find_ended_task(ref, state) do
      nil ->
        noreply_unknown_ref(ref, "received DOWN", state)

      %{running_command: {context, _, _} = running_command} ->
        Logger.debug(
          "task executing command #{inspect(running_command)} failed with reason #{
            inspect(reason)
          }"
        )

        {:noreply,
         context
         |> assemble_worker_state(state)
         |> handle_task_error(reason)
         |> handle_answer()
         |> update_worker(state)}
    end
  end

  def queue_or_execute(%{module: module, running_command: nil} = worker_state, command) do
    task =
      Task.Supervisor.async_nolink(
        worker_state.task_supervisor_module,
        fn ->
          module.execute(command)
          |> store_events(worker_state.event_bus_module)
        end
      )

    %{worker_state | running_command: command, running_ref: task.ref}
  end

  def queue_or_execute(%{queue: queue} = worker_state, command) do
    %{worker_state | queue: :queue.in(command, queue)}
  end

  def store_events(events, event_bus_module) do
    EventBus.add_events(event_bus_module, events)
  end

  defp find_ended_task(ref, state) do
    Enum.find(state.workers, &(&1.running_ref == ref))
  end

  defp handle_task_error(worker, reason) do
    # add_command({:sim_stop})
    events = [{:command_failed, command: worker.running_command, reason: reason}]
    store_events(events, worker.event_bus_module)
    worker
  end

  defp handle_answer(worker) do
    worker = %{worker | running_ref: nil, running_command: nil}

    case :queue.out(worker.queue) do
      {{:value, command}, queue} -> queue_or_execute(%{worker | queue: queue}, command)
      {:empty, _queue} -> worker
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
