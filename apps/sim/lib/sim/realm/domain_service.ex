defmodule Sim.Realm.DomainService do
  use GenStage
  require Logger

  def start_link([domain_service: {domain_service, _}, worker_supervisor: _] = opts) do
    GenStage.start_link(__MODULE__, opts, name: domain_service)
  end

  def init(
        domain_service: {domain_service, [subscribe_to: [{_, opts}]] = subscribe_to},
        worker_supervisor: worker_supervisor
      ) do
    Logger.debug("DomainService #{opts[:partition]} started with max_demand #{opts[:max_demand]}")

    {:producer_consumer, %{domain_service: domain_service, worker_supervisor: worker_supervisor},
     subscribe_to}
  end

  def handle_events(commands, _from, state) do
    events =
      commands
      |> execute(state.domain_service, state.worker_supervisor)
      |> filter()
      |> List.flatten()

    {:noreply, events, state}
  end

  def execute(commands, domain_service, worker_supervisor) do
    worker_supervisor
    |> Task.Supervisor.async_stream_nolink(commands, fn {command, args} ->
      domain_service.execute(command, args)
    end)
    |> Enum.to_list()
  end

  def filter(events) do
    Enum.map(events, fn event ->
      case event do
        {:exit, {:undef, [msg | _stacktrace]}} ->
          {:error, "exited with undef #{inspect(msg)}, probably an UndefinedFunctionError"}

        {:exit, {reason, [msg | _stacktrace]}} when is_atom(reason) ->
          {:error, "exited with #{reason} #{inspect(msg)}"}

        {:exit, {exception, _stacktrace}} ->
          {:error, Exception.message(exception)}

        {:exit, unknown} ->
          {:error, "unknown error: #{inspect(unknown)}"}

        {:ok, {:error, msg}} ->
          {:error, msg}

        {:ok, [{_command, _result} | _] = returned_events} ->
          returned_events
      end
    end)
  end
end
