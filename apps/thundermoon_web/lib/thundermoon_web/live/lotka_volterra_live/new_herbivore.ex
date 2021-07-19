defmodule ThundermoonWeb.LotkaVolterraLive.NewHerbivore do
  use ThundermoonWeb.Component.EntityForm,
    params_name: "herbivore",
    model: LotkaVolterra.Herbivore,
    form_data: Thundermoon.LotkaVolterra.AnimalFormData

  alias LotkaVolterra.Herbivore
  alias Thundermoon.LotkaVolterra.AnimalFormData

  @impl true
  def handle_event("add_predator", _params, socket) do
    case AnimalFormData.apply_action(socket.assigns.changeset, :update) do
      {:ok, herbivore} ->
        send(self(), {:entity_added, herbivore})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, validation_failed(socket, changeset, "creating herbivore failed")}
    end
  end

  def entity_submitted(%Herbivore{} = herbivore, %{assigns: %{sim_id: sim_id}} = socket) do
    LotkaVolterra.update_object(sim_id, fn {vegetation, _old_herbivore, predators} ->
      {vegetation, herbivore, predators}
    end)

    socket
    |> put_flash(:info, "successfully updated herbivore")
  end

  def entity_submitted(%Herbivore{} = herbivore, socket) do
    {sim_id, _object} =
      LotkaVolterra.create({socket.assigns.vegetation, herbivore, nil}, ThundermoonWeb.PubSub)

    send(self(), {:object_created, sim_id})

    socket
    |> put_flash(:info, "successfully created herbivore")
  end
end
