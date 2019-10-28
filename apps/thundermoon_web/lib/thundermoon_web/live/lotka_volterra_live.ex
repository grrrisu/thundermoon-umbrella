defmodule ThundermoonWeb.LotkaVolterraLive do
  use Phoenix.LiveView

  alias Thundermoon.LotkaVolterra

  alias ThundermoonWeb.Endpoint
  alias ThundermoonWeb.LotkaVolterraView

  def mount(_session, socket) do
    if connected?(socket), do: Endpoint.subscribe("Thundermoon.LotkaVolterra")
    socket = set_label_sim_start(socket, LotkaVolterra.started?())
    {:ok, socket}
  end

  def render(assigns) do
    LotkaVolterraView.render("index.html", assigns)
  end

  def handle_event("create", _params, socket) do
    {:ok, session_ref} = LotkaVolterra.create()
    {:noreply, assign(socket, session_ref: session_ref)}
  end

  def handle_event("toggle-sim-start", %{"action" => "start"}, socket) do
    LotkaVolterra.start()
    {:noreply, socket}
  end

  def handle_event("toggle-sim-start", %{"action" => "stop"}, socket) do
    LotkaVolterra.stop()
    {:noreply, socket}
  end

  def handle_info(%{event: "sim", payload: %{started: started}}, socket) do
    {:noreply, set_label_sim_start(socket, started)}
  end

  defp set_label_sim_start(socket, started) do
    label = if started, do: "stop", else: "start"
    assign(socket, label_sim_start: label)
  end
end
