defmodule ThundermoonWeb.LotkaVolterra.Index do
  use ThundermoonWeb, :live_view

  alias Phoenix.PubSub

  @impl true
  def mount(%{"sim_id" => sim_id}, _session, socket) do
    {:ok,
     socket
     |> set_simulation(sim_id)
     |> assign(started: false)}
  end

  @impl true
  def mount(%{}, _session, socket) do
    {:ok,
     socket
     |> push_redirect(to: Routes.live_path(socket, ThundermoonWeb.LotkaVolterra.New))}
  end

  @impl true
  def handle_info(:start, socket) do
    LotkaVolterra.start(socket.assigns.sim_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:stop, socket) do
    LotkaVolterra.stop(socket.assigns.sim_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, data: vegetation}, socket) do
    {:noreply, assign(socket, vegetation: vegetation)}
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
        if connected?(socket), do: subscribe_to_sim(sim_id)
        assign(socket, sim_id: sim_id, vegetation: vegetation)
    end
  end

  defp subscribe_to_sim(sim_id) do
    PubSub.subscribe(ThundermoonWeb.PubSub, sim_id)
  end
end
