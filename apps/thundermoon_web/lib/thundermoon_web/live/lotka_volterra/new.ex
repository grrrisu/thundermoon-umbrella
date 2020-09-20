defmodule ThundermoonWeb.LotkaVolterraLive.New do
  use ThundermoonWeb, :live_view

  alias Thundermoon.LotkaVolterra.{VegetationForm, HerbivoreForm}
  alias LotkaVolterra.{Vegetation, Herbivore}

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"model" => "herbivore"}, _url, socket) do
    Logger.info("add herbivore")
    {:noreply, assign(socket, changeset: empty_form(:herbivore))}
  end

  @impl true
  def handle_params(%{}, _url, socket) do
    {:noreply, assign(socket, changeset: empty_form(:vegetation))}
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
  def handle_event("validate", %{"herbivore" => params}, socket) do
    changeset =
      %Herbivore{}
      |> HerbivoreForm.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("create", %{"vegetation" => _} = params, socket) do
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

  @impl true
  def handle_event("create", %{"herbivore" => _} = params, socket) do
    case apply_params(params) do
      {:ok, herbivore} ->
        sim_id = create_sim(socket.assigns.vegetation, herbivore)

        {:noreply,
         socket
         |> put_flash(:info, "successfully created herbivore")
         |> push_redirect(to: Routes.lotka_volterra_index_path(socket, :index, sim_id: sim_id))}

      {:error, changeset} ->
        {:noreply, validation_failed(socket, changeset, "creating herbivore failed")}
    end
  end

  defp validation_failed(socket, changeset, message) do
    socket
    |> put_flash(:error, message)
    |> assign(changeset: changeset)
  end

  defp apply_params(%{"vegetation" => params}) do
    VegetationForm.changeset(%Vegetation{}, params)
    |> VegetationForm.apply_valid_changes()
  end

  defp apply_params(%{"herbivore" => params}) do
    HerbivoreForm.changeset(%Herbivore{}, params)
    |> HerbivoreForm.apply_valid_changes()
  end

  defp create_sim(vegetation, herbivore \\ nil) do
    {sim_id, _object} = LotkaVolterra.create({vegetation, herbivore}, ThundermoonWeb.PubSub)
    sim_id
  end

  defp empty_form(:vegetation) do
    VegetationForm.changeset(%Vegetation{})
  end

  defp empty_form(:herbivore) do
    HerbivoreForm.changeset(%Herbivore{})
  end
end
