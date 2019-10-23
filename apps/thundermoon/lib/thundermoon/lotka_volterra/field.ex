defmodule Thundermoon.Field do
  # agent is temporary as it will be restarted by the counter
  use Agent, restart: :temporary

  alias Thundermoon.Vegetation

  alias ThundermoonWeb.Endpoint

  def start() do
    Agent.start(fn ->
      vegetation = %Vegetation{}
      broadcast(vegetation.size)
      %{vegetation: vegetation}
    end)
  end

  def tick(field) do
    Agent.get_and_update(field, fn state ->
      new_size = state.vegetation.size + Vegetation.delta(state.vegetation)
      new_vegetation = %Vegetation{state.vegetation | size: new_size}
      broadcast(new_size)
      {new_size, %{state | vegetation: new_vegetation}}
    end)
  end

  defp broadcast(size) do
    Endpoint.broadcast("Thundermoon.LotkaVolterra", "update", %{vegetation: size})
  end
end
