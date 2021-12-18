defmodule GameOfLife.PubSubReducer do
  def reduce(events) do
    Enum.map(events, fn event ->
      Phoenix.PubSub.broadcast(ThundermoonWeb.PubSub, "GameOfLife", event)
    end)
  end
end
