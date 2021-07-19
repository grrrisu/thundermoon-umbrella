defmodule ThundermoonWeb.LotkaVolterraLive.NewVegetation do
  use ThundermoonWeb.Component.EntityForm,
    params_name: "vegetation",
    model: LotkaVolterra.Vegetation,
    form_data: Thundermoon.LotkaVolterra.VegetationForm

  alias LotkaVolterra.Vegetation
  alias Thundermoon.LotkaVolterra.VegetationForm

  @impl true
  def handle_event("add_herbivore", _params, socket) do
    case VegetationForm.apply_action(socket.assigns.changeset, :update) do
      {:ok, vegetation} ->
        send(self(), {:entity_added, vegetation})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, validation_failed(socket, changeset, "creating vegetation failed")}
    end
  end

  def entity_submitted(%Vegetation{} = vegetation, %{assigns: %{sim_id: sim_id}} = socket) do
    LotkaVolterra.update_object(sim_id, fn {_old_vegetation, herbivore, predators} ->
      {vegetation, herbivore, predators}
    end)

    socket
    |> put_flash(:info, "successfully updated vegetation")
  end

  def entity_submitted(%Vegetation{} = vegetation, socket) do
    {sim_id, _object} = LotkaVolterra.create({vegetation, nil, nil}, ThundermoonWeb.PubSub)

    send(self(), {:object_created, sim_id})

    socket
    |> put_flash(:info, "successfully created vegetation")
  end
end
