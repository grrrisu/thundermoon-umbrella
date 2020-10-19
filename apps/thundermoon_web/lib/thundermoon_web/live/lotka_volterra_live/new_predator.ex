defmodule ThundermoonWeb.LotkaVolterraLive.NewPredator do
  use ThundermoonWeb.Component.EntityForm,
    params_name: "predator",
    model: LotkaVolterra.Predator,
    form_data: Thundermoon.LotkaVolterra.HerbivoreForm

  def render(assigns) do
    ThundermoonWeb.LotkaVolterraLive.NewHerbivore.render(assigns)
  end
end
