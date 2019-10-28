defmodule Thundermoon.Field do
  # agent is temporary as it will be restarted by the counter
  use Agent, restart: :temporary

  alias Thundermoon.Vegetation

  alias ThundermoonWeb.PubSub

  def start_link(_args \\ nil) do
    Agent.start_link(fn ->
      vegetation = %Vegetation{}
      %{vegetation: vegetation}
    end)
  end

  def tick(field) do
    Agent.get_and_update(field, fn state ->
      new_vegetation = Vegetation.sim(state.vegetation)
      {new_vegetation.size, %{state | vegetation: new_vegetation}}
    end)
  end

  defp broadcast(size) do
    Phoenix.PubSub.broadcast(PubSub, "Thundermoon.LotkaVolterra", {:update, vegetation: size})
  end
end
