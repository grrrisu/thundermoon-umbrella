defmodule ThundermoonWeb.LotkaVolterra.Index do
  use ThundermoonWeb, :live_view

  alias Phoenix.PubSub

  @impl true
  def mount(%{"sim_id" => sim_id}, _session, socket) do
    {:ok,
     socket
     |> set_simulation(sim_id)
     |> assign(started: false)
     |> assign(x_axe: 0)}
  end

  @impl true
  def mount(%{}, _session, socket) do
    {:ok,
     socket
     |> push_redirect(to: Routes.live_path(socket, ThundermoonWeb.LotkaVolterra.New))}
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

  defp set_simulation(socket, sim_id) do
    case LotkaVolterra.object(sim_id) do
      {:error, :not_found} ->
        socket
        |> put_flash(:error, "simulation not found, create a new one")
        |> push_redirect(to: Routes.live_path(socket, ThundermoonWeb.LotkaVolterra.New))

      vegetation ->
        if connected?(socket) do
          subscribe_to_sim(sim_id)
        end

        socket
        |> push_event("update-chart", %{x_axe: 0, vegetation: vegetation.size})
        |> assign(sim_id: sim_id, vegetation: vegetation)
    end
  end

  defp subscribe_to_sim(sim_id) do
    PubSub.subscribe(ThundermoonWeb.PubSub, sim_id)
  end
end
