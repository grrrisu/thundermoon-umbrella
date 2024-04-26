defmodule LotkaVolterra.Predator do
  defstruct birth_rate: 0.3,
            death_rate: 0.01,
            needed_food: 2,
            starving_rate: 0.5,
            graze_rate: 0.1,
            size: 10
end
