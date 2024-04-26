defmodule LotkaVolterra.Herbivore do
  defstruct birth_rate: 0.5,
            death_rate: 0.01,
            needed_food: 5,
            starving_rate: 0.8,
            graze_rate: 0.05,
            size: 150
end
