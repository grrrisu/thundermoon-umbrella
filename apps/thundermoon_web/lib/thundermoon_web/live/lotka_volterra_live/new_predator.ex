defmodule ThundermoonWeb.LotkaVolterraLive.NewPredator do
  use ThundermoonWeb.Component.EntityForm,
    params_name: "predator",
    model: LotkaVolterra.Predator,
    form_data: Thundermoon.LotkaVolterra.AnimalForm
end
