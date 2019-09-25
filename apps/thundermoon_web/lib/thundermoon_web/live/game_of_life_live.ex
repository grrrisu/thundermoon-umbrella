defmodule ThundermoonWeb.GameOfLifeLive do
  use Phoenix.LiveView

  alias Thundermoon.GameOfLife

  alias ThundermoonWeb.GameOfLifeView
  alias ThundermoonWeb.Endpoint

  def mount(_session, socket) do
    if connected?(socket), do: Endpoint.subscribe("Thundermoon.GameOfLife")
    grid = GameOfLife.get_grid()
    {:ok, assign(socket, grid: grid)}
  end

  def render(assigns) do
    GameOfLifeView.render("index.html", assigns)
  end

  # this is triggered by live_view events
  def handle_event("create", %{"grid" => %{"size" => size}}, socket) do
    GameOfLife.create(String.to_integer(size))
    {:noreply, socket}
  end

  def handle_info(%{event: "sim", payload: %{started: _started}}, socket) do
    {:noreply, socket}
  end

  # this is triggered by the pubsub broadcast event
  def handle_info(%{event: "update", payload: %{grid: grid}}, socket) do
    {:noreply, assign(socket, grid: grid)}
  end
end
