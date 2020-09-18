defmodule ThundermoonWeb.LotkaVolterraLive.New do
  use ThundermoonWeb, :live_view

  alias Thundermoon.LotkaVolterra.VegetationForm
  alias LotkaVolterra.{Vegetation, Herbivore}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{}, url, socket) do
    {:noreply, assign(socket, changeset: empty_form())}
  end

  def handle_params(%{"model" => "herbivore"}, url, socket) do
    {:noreply, assign(socket, changeset: empty_form())}
  end

  def handle_event("add_herbivore", _params, socket) do
    case VegetationForm.apply_valid_changes(socket.assigns.changeset) do
      {:ok, vegetation} ->
        {:noreply,
         socket
         |> assign(vegetation: vegetation)
         |> push_patch(to: Routes.lotka_volterra_new_path(socket, :new, model: "herbivore"))}

      {:error, changeset} ->
        {:noreply, validation_failed(socket, changeset, "creating vegetation failed")}
    end
  end

  @impl true
  def handle_event("validate", %{"vegetation" => params}, socket) do
    changeset =
      %Vegetation{}
      |> VegetationForm.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("create", %{"vegetation" => params} = p, socket) do
    case apply_params(params) do
      {:ok, vegetation} ->
        sim_id = create_sim(vegetation)

        {:noreply,
         socket
         |> put_flash(:info, "successfully created vegetation")
         |> push_redirect(to: Routes.lotka_volterra_index_path(socket, :index, sim_id: sim_id))}

      {:error, changeset} ->
        {:noreply, validation_failed(socket, changeset, "creating vegetation failed")}
    end
  end

  defp validation_failed(socket, changeset, message) do
    socket
    |> put_flash(:error, message)
    |> assign(changeset: changeset)
  end

  defp apply_params(params) do
    VegetationForm.changeset(%Vegetation{}, params)
    |> VegetationForm.apply_valid_changes()
  end

  defp create_sim(vegetation, herbivore \\ nil) do
    {sim_id, _object} = LotkaVolterra.create({vegetation, herbivore}, ThundermoonWeb.PubSub)
    sim_id
  end

  defp empty_form() do
    VegetationForm.changeset(%Vegetation{})
  end
end
