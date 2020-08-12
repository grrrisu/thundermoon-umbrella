defmodule Thundermoon.LotkaVolterra do
  require Logger

  alias Thundermoon.{SimContainer, Field}
  alias Thundermoon.LotkaVolterra.{Realm, SimulationLoop}

  alias ThundermoonWeb.Endpoint

  def create() do
    GenServer.call(Realm, {:create, SimContainer, Thundermoon.LotkaVolterra.ObjectSupervisor})
    SimContainer.add(%{object_module: Field})
  end

  def start() do
    func = fn ->
      sessions = SimContainer.get_sessions()

      Enum.each(sessions, fn session ->
        new_size = Field.tick(session.subject_pid)
        broadcast(session, new_size)
      end)
    end

    GenServer.cast(SimulationLoop, {:start, func})
  end

  def stop() do
    GenServer.cast(SimulationLoop, :stop)
  end

  def started?() do
    GenServer.call(SimulationLoop, :started?)
  end

  defp broadcast(session, size) do
    session.listener_pid
    |> send(%{event: "update", payload: %{vegetation: size}})
  end
end