defmodule ThundermoonWeb.Component.StartButton do
  use ThundermoonWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(icon: set_icon(assigns.started))
     |> assign(label: set_label(assigns.started))}
  end

  def render(assigns) do
    ~L"""
    <a href="#" id="start-button" phx-click="toggle-sim-start" phx-value-action="<%= @label %>" phx-target="<%= @myself %>" class="button button-icon">
      <i class="la la-2x <%= @icon %>"></i><%= @label %>
    </a>
    """
  end

  @impl true
  def handle_event("toggle-sim-start", %{"action" => "start"}, socket) do
    send(self(), :start)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle-sim-start", %{"action" => "stop"}, socket) do
    send(self(), :stop)
    {:noreply, socket}
  end

  defp set_icon(false), do: "la-play"
  defp set_icon(true), do: "la-pause"

  defp set_label(false), do: "start"
  defp set_label(true), do: "stop"
end
