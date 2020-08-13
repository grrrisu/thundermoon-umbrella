defmodule ThundermoonWeb.LotkaVolterra.Index do
  use ThundermoonWeb, :live_view

  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(started: false)
     |> assign(x_axe: 0)
     |> assign(vegetation: %{size: 0})}
  end

  @impl true
  def handle_event("create", _params, socket) do
    {sim_id, vegetation} = create()

    {:noreply,
     socket
     |> assign(vegetation: vegetation, sim_id: sim_id, x_axe: 0)
     |> push_event("update-chart", %{
       x_axe: 0,
       vegetation: vegetation.size
     })}
  end

  @impl true
  def handle_event("toggle-sim-start", %{"action" => "start"}, socket) do
    LotkaVolterra.start(socket.assigns.sim_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle-sim-start", %{"action" => "stop"}, socket) do
    LotkaVolterra.stop(socket.assigns.sim_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, data: vegetation}, socket) do
    {:noreply,
     socket
     |> assign(x_axe: socket.assigns.x_axe + 1, vegetation: vegetation)
     |> push_event("update-chart", %{
       x_axe: socket.assigns.x_axe + 1,
       vegetation: vegetation.size
     })}
  end

  @impl true
  def handle_info({:sim, started: started}, socket) do
    {:noreply, assign(socket, started: started)}
  end

  @impl true
  def terminate(_reason, socket) do
    if Map.has_key?(socket.assigns, :sim_id), do: LotkaVolterra.delete(socket.assigns.sim_id)
  end

  defp create() do
    {sim_id, object} = LotkaVolterra.create(ThundermoonWeb.PubSub)
    subscribe_to_sim(sim_id)
    {sim_id, object}
  end

  defp subscribe_to_sim(sim_id) do
    PubSub.subscribe(ThundermoonWeb.PubSub, sim_id)
  end
end
