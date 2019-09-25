defmodule ThundermoonWeb.GameOfLifeLive do
  use Phoenix.LiveView

  alias Thundermoon.GameOfLife

  alias ThundermoonWeb.GameOfLifeView
  alias ThundermoonWeb.Endpoint

  def mount(_session, socket) do
    if connected?(socket), do: Endpoint.subscribe("Thundermoon.GameOfLife")
    grid = GameOfLife.get_grid()
    socket = set_label_sim_start(socket, GameOfLife.started?())
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

  def handle_event("toggle-sim-start", %{"action" => "start"}, socket) do
    GameOfLife.start()
    {:noreply, socket}
  end

  def handle_event("toggle-sim-start", %{"action" => "stop"}, socket) do
    GameOfLife.stop()
    {:noreply, socket}
  end

  def handle_info(%{event: "sim", payload: %{started: started}}, socket) do
    {:noreply, set_label_sim_start(socket, started)}
  end

  # this is triggered by the pubsub broadcast event
  def handle_info(%{event: "update", payload: %{grid: grid}}, socket) do
    {:noreply, assign(socket, grid: grid)}
  end

  defp set_label_sim_start(socket, started) do
    label = if started, do: "stop", else: "start"
    assign(socket, label_sim_start: label)
  end
end
