defmodule LotkaVolterra.Sim.Animal do
  # population grows by birth rate and and and shrinks by death rate (age) and hunger.
  # Hunger is the ratio of needed food and food available multiplied by starving_rate.
  # The food consumed is proportional to the size of the population multiplied by graze_rate.
  #
  # b : birth_rate
  # d : death_rate
  # f : needed_food per unit
  # g : graze_rate / hunt_rate
  # a : starving_rate
  # s : size
  # v : producer.size
  #

  # Δv = - f s g

  #                s f
  # Δs = s (b - a ------  - d)
  #                 v

  def sim(producer, nil), do: {producer, nil}

  def sim(%{size: producer_size} = producer, %{size: size} = animal, step \\ 1) do
    producer_size = producer_size - delta_producer(animal, producer_size) * step
    animal_size = size + delta_animal(animal, producer_size) * step

    {Map.put(producer, :size, producer_size), Map.put(animal, :size, animal_size)}
  end

  def delta_producer(
        %{
          needed_food: needed_food,
          graze_rate: graze_rate,
          size: size
        },
        producer_size
      ) do
    (needed_food * size * graze_rate)
    |> max_consumed_food(producer_size)
  end

  defp max_consumed_food(consumed_food, producer) when producer - consumed_food < 0 do
    0
  end

  defp max_consumed_food(consumed_food, _producer), do: consumed_food

  def delta_animal(
        %{
          birth_rate: birth_rate,
          death_rate: death_rate,
          needed_food: needed_food,
          starving_rate: starving_rate,
          size: size
        },
        producer_size
      ) do
    hunger_rate = starving_rate * (size * needed_food / producer_size)

    (size * (birth_rate - hunger_rate - death_rate))
    |> min_grown_size(size, starving_rate)
  end

  defp min_grown_size(grown_size, size, starving_rate) when size + grown_size < 0 do
    -size * starving_rate * 2
  end

  defp min_grown_size(grown_size, _size, _starving_rate), do: grown_size
end
