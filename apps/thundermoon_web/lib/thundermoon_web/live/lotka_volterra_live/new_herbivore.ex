defmodule ThundermoonWeb.LotkaVolterraLive.NewHerbivore do
  use ThundermoonWeb.LotkaVolterra.Entity,
    params_name: "herbivore",
    model: LotkaVolterra.Herbivore,
    form_data: Thundermoon.LotkaVolterra.HerbivoreForm
end
