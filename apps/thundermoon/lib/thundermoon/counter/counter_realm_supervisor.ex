defmodule Thundermoon.CounterRealmSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Thundermoon.CounterRealm, name: Thundermoon.CounterRealm},
      {DynamicSupervisor, name: Thundermoon.CounterSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: Thundermoon.DigitSupervisor, strategy: :one_for_one},
      {Thundermoon.CounterSimulation, name: Thundermoon.CounterSimulation}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
