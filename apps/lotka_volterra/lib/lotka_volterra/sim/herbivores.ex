defmodule LotkaVolterra.Sim.Herbivores do
  alias LotkaVolterra.{Vegetation, Herbivore}

  # population grows by birth rate and and the food they can graze / eat
  # and shrink by the death rate. The difference between birth rate and death rate
  # represents the starving rate in absence of food.
  #
  # b : birth_rate
  # d : death_rate
  # g : graze_rate
  # s : size
  # v : vegetation.size
  #
  # Δs = s (b - d) + g*v

  def delta(
        %Herbivore{
          birth_rate: birth_rate,
          death_rate: death_rate,
          graze_rate: graze_rate,
          size: size
        },
        vegetation
      ) do
    consumed_food = vegetation * graze_rate
    {size * -death_rate + 0.5 * consumed_food, consumed_food}
  end

  def sim(vegetation, nil), do: {vegetation, nil}

  def sim(%Vegetation{} = vegetation, %Herbivore{size: size} = herbivore, step \\ 1) do
    {grown_size, consumed_food} = delta(herbivore, vegetation.size)

    {%Vegetation{vegetation | size: vegetation.size - consumed_food * step},
     %Herbivore{herbivore | size: size + grown_size * step}}
  end
end
