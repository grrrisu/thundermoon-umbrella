defmodule ThundermoonWeb.LotkaVolterraLive.Index do
  use ThundermoonWeb, :live_view

  alias Phoenix.PubSub

  import ThundermoonWeb.Component.Actions

  alias ThundermoonWeb.LotkaVolterraLive.{
    Chart,
    EditButton,
    VegetationForm,
    HerbivoreForm,
    PredatorForm
  }

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
     |> push_navigate(to: ~p"/lotka-volterra/new")}
  end

  @impl true
  def handle_event("start", _, socket) do
    LotkaVolterra.start(socket.assigns.sim_id)
    {:noreply, put_flash(socket, :info, "simulation started")}
  end

  @impl true
  def handle_event("stop", _, socket) do
    LotkaVolterra.stop(socket.assigns.sim_id)
    {:noreply, put_flash(socket, :info, "simulation stopped")}
  end

  @impl true
  def handle_info({:update, data: field}, socket) do
    {vegetation, herbivore, predator} = field

    {:noreply,
     assign(socket,
       field: field,
       vegetation: vegetation,
       herbivore: herbivore,
       predator: predator
     )}
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
        |> push_navigate(to: ~p"/lotka-volterra/new")

      {vegation, herbivore, predator} = field ->
        if connected?(socket), do: subscribe_to_sim(sim_id)

        assign(socket,
          sim_id: sim_id,
          field: field,
          vegetation: vegation,
          herbivore: herbivore,
          predator: predator
        )
    end
  end

  defp subscribe_to_sim(sim_id) do
    PubSub.subscribe(ThundermoonWeb.PubSub, sim_id)
  end
end
