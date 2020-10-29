defmodule ThundermoonWeb.LotkaVolterraLive.New do
  use ThundermoonWeb, :live_view

  alias LotkaVolterra.{Vegetation, Herbivore, Predator}

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"model" => "predator"}, _url, socket) do
    case Map.has_key?(socket.assigns, :herbivore) do
      false ->
        {:noreply, push_patch(socket, to: Routes.lotka_volterra_new_path(socket, :new))}

      true ->
        Logger.info("add predator")
        {:noreply, assign(socket, entity: :predator)}
    end
  end

  @impl true
  def handle_params(%{"model" => "herbivore"}, _url, socket) do
    case Map.has_key?(socket.assigns, :vegetation) do
      false ->
        {:noreply, push_patch(socket, to: Routes.lotka_volterra_new_path(socket, :new))}

      true ->
        Logger.info("add herbivore")
        {:noreply, assign(socket, entity: :herbivore)}
    end
  end

  @impl true
  def handle_params(%{}, _url, socket) do
    {:noreply, assign(socket, entity: :vegetation)}
  end

  @impl true
  def handle_info({:entity_submitted, %Vegetation{} = vegetation}, socket) do
    sim_id = create_sim(vegetation)

    {:noreply,
     socket
     |> put_flash(:info, "successfully created vegetation")
     |> push_redirect(to: Routes.lotka_volterra_index_path(socket, :index, sim_id: sim_id))}
  end

  @impl true
  def handle_info({:entity_submitted, %Herbivore{} = herbivore}, socket) do
    sim_id = create_sim(socket.assigns.vegetation, herbivore)

    {:noreply,
     socket
     |> put_flash(:info, "successfully created herbivore")
     |> push_redirect(to: Routes.lotka_volterra_index_path(socket, :index, sim_id: sim_id))}
  end

  @impl true
  def handle_info({:entity_submitted, %Predator{} = predator}, socket) do
    sim_id = create_sim(socket.assigns.vegetation, socket.assigns.herbivore, predator)

    {:noreply,
     socket
     |> put_flash(:info, "successfully created predator")
     |> push_redirect(to: Routes.lotka_volterra_index_path(socket, :index, sim_id: sim_id))}
  end

  @impl true
  def handle_info({:entity_added, %Vegetation{} = vegetation}, socket) do
    {:noreply,
     socket
     |> assign(vegetation: vegetation)
     |> push_patch(to: Routes.lotka_volterra_new_path(socket, :new, model: "herbivore"))}
  end

  @impl true
  def handle_info({:entity_added, %Herbivore{} = herbivore}, socket) do
    {:noreply,
     socket
     |> assign(herbivore: herbivore)
     |> push_patch(to: Routes.lotka_volterra_new_path(socket, :new, model: "predator"))}
  end

  defp create_sim(vegetation, herbivore \\ nil, predator \\ nil) do
    {sim_id, _object} =
      LotkaVolterra.create({vegetation, herbivore, predator}, ThundermoonWeb.PubSub)

    sim_id
  end
end
