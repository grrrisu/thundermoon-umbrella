defmodule LotkaVolterra.Sim.Herbivores do
  alias LotkaVolterra.{Vegetation, Herbivore}

  # population grows by birth rate and and and shrinks by death rate (age) and hunger.
  # Hunger is the ratio of needed food and food available multiplied by starving_rate.
  # The food consumed is proportional to the size of the population multiplied by graze_rate.
  #
  # b : birth_rate
  # d : death_rate
  # f : needed_food per unit
  # g : graze_rate
  # a : starving_rate
  # s : size
  # v : vegetation.size
  #

  # Δv = - f s g

  #                s f
  # Δs = s (b - a ------  - d)
  #                 v

  def sim(vegetation, nil), do: {vegetation, nil}

  def sim(%Vegetation{} = vegetation, %Herbivore{size: size} = herbivore, step \\ 1) do
    vegetation_size = vegetation.size - delta_vegetation(herbivore, vegetation) * step
    herbivore_size = size + delta_herbivore(herbivore, vegetation) * step

    {%Vegetation{vegetation | size: vegetation_size},
     %Herbivore{herbivore | size: herbivore_size}}
  end

  def delta_vegetation(
        %Herbivore{
          needed_food: needed_food,
          graze_rate: graze_rate,
          size: size
        },
        %Vegetation{size: vegetation}
      ) do
    (needed_food * size * graze_rate)
    |> max_consumed_food(vegetation)
  end

  defp max_consumed_food(consumed_food, vegetation) when vegetation - consumed_food < 0 do
    0
  end

  defp max_consumed_food(consumed_food, _vegetation), do: consumed_food

  def delta_herbivore(
        %Herbivore{
          birth_rate: birth_rate,
          death_rate: death_rate,
          needed_food: needed_food,
          starving_rate: starving_rate,
          size: size
        },
        %Vegetation{size: vegetation}
      ) do
    hunger_rate = starving_rate * (size * needed_food / vegetation)

    (size * (birth_rate - hunger_rate - death_rate))
    |> min_grown_size(size, starving_rate)
  end

  defp min_grown_size(grown_size, size, starving_rate) when size + grown_size < 0 do
    -size * starving_rate * 2
  end

  defp min_grown_size(grown_size, _size, _starving_rate), do: grown_size
end
