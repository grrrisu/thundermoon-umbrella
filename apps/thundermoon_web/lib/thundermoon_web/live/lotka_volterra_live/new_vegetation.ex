defmodule ThundermoonWeb.LotkaVolterraLive.NewVegetation do
  use ThundermoonWeb.Component.EntityForm,
    params_name: "vegetation",
    model: LotkaVolterra.Vegetation,
    form_data: Thundermoon.LotkaVolterra.VegetationForm

  alias Thundermoon.LotkaVolterra.VegetationForm

  @impl true
  def handle_event("add_herbivore", _params, socket) do
    case VegetationForm.apply_valid_changes(socket.assigns.changeset) do
      {:ok, vegetation} ->
        send(self(), {:entity_added, vegetation})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, validation_failed(socket, changeset, "creating vegetation failed")}
    end
  end
end
