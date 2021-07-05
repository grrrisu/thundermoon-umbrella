defmodule ThundermoonWeb.LotkaVolterraLive.NewPredator do
  use ThundermoonWeb.Component.EntityForm,
    params_name: "predator",
    model: LotkaVolterra.Predator,
    form_data: Thundermoon.LotkaVolterra.AnimalForm

  alias LotkaVolterra.Predator

  def entity_submitted(%Predator{} = predator, %{assigns: %{sim_id: sim_id}} = socket) do
    LotkaVolterra.update_object(sim_id, fn {vegetation, herbivore, _old_predator} ->
      {vegetation, herbivore, predator}
    end)

    socket
    |> put_flash(:info, "successfully updated predators")
  end

  def entity_submitted(%Predator{} = predator, socket) do
    {sim_id, _object} =
      LotkaVolterra.create(
        {socket.assigns.vegetation, socket.assigns.herbivore, predator},
        ThundermoonWeb.PubSub
      )

    send(self(), {:object_created, sim_id})

    socket
    |> put_flash(:info, "successfully created herbivore")
  end
end
