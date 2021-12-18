defmodule Sim.Realm.DomainService do
  use GenStage
  require Logger

  def start_link([service: {_, domain_service}, command_bus: _] = opts) do
    GenStage.start_link(__MODULE__, opts, name: domain_service)
  end

  def init(service: {partition, domain_service}, command_bus: command_bus) do
    Logger.info("DomainService #{partition} started")

    {:producer_consumer, %{domain_service: domain_service},
     subscribe_to: [{command_bus || Sim.Realm.CommandBus, partition: partition}]}
  end

  def handle_events(events, _from, state) do
    events = events |> execute(state.domain_service) |> filter()
    {:noreply, events, state}
  end

  def execute(events, domain_service) do
    WorkerSupervisor
    |> Task.Supervisor.async_stream_nolink(events, fn event -> domain_service.execute(event) end)
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
