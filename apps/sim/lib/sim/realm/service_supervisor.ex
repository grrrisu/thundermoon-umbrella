defmodule Sim.Realm.ServiceSupervisor do
  use Supervisor

  alias Sim.Realm.DomainService

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(opts) do
    worker_supervisor = {Task.Supervisor, name: task_supervisor_name(opts)}
    children = [worker_supervisor | service_specs(opts)]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def service_specs(opts) do
    Enum.map(opts[:domain_services], fn {_key, module} = service ->
      Supervisor.child_spec(
        {DomainService, [service: service, command_bus: opts[:command_bus]]},
        id: module
      )
    end)
  end

  defp task_supervisor_name(opts) do
    if Keyword.has_key?(opts, :name) do
      Module.concat(opts[:name], WorkerSupervisor)
    else
      Sim.Realm.WorkerSupervisor
    end
  end
end
