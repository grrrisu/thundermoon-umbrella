defmodule ThundermoonWeb.LotkaVolterraLive.NewHerbivore do
  use ThundermoonWeb.Component.EntityForm,
    params_name: "herbivore",
    model: LotkaVolterra.Herbivore,
    form_data: Thundermoon.LotkaVolterra.HerbivoreForm

  alias Thundermoon.LotkaVolterra.HerbivoreForm

  @impl true
  def handle_event("add_predator", _params, socket) do
    case HerbivoreForm.apply_valid_changes(socket.assigns.changeset) do
      {:ok, herbivore} ->
        send(self(), {:entity_added, herbivore})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, validation_failed(socket, changeset, "creating herbivore failed")}
    end
  end
end
