defmodule ThundermoonWeb.LotkaVolterra.Index do
  use ThundermoonWeb, :live_view

  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(started: false)
     |> assign(vegetation: %{size: 0})}
  end

  @impl true
  def handle_event("create", _params, socket) do
    {sim_id, vegetation} = create()
    {:noreply, assign(socket, vegetation: vegetation, sim_id: sim_id)}
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
    {:noreply, assign(socket, :vegetation, vegetation)}
  end

  @impl true
  def handle_info({:sim, started: started}, socket) do
    {:noreply, assign(socket, started: started)}
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
