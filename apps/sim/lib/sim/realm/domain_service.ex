defmodule Sim.Realm.DomainService do
  use GenStage
  require Logger

  def start_link([domain_service: {domain_service, _}] = opts) do
    GenStage.start_link(__MODULE__, opts, name: domain_service)
  end

  def init(domain_service: {domain_service, [subscribe_to: [{_, opts}]] = subscribe_to}) do
    Logger.debug("DomainService #{opts[:partition]} started with max_demand #{opts[:max_demand]}")

    {:producer_consumer, %{domain_service: domain_service}, subscribe_to}
  end

  def handle_events(events, _from, state) do
    events = events |> execute(state.domain_service) |> filter()
    {:noreply, events, state}
  end

  def execute(events, domain_service) do
    WorkerSupervisor
    |> Task.Supervisor.async_stream_nolink(events, fn {command, args} ->
      domain_service.execute(command, args)
    end)
    |> Enum.to_list()
  end

  def filter(events) do
    Enum.map(events, fn event ->
      case event do
        {:exit, {exception, _stacktrace}} -> {:error, Exception.message(exception)}
        {:ok, {:error, msg}} -> {:error, msg}
        result -> result
      end
    end)
  end
end
