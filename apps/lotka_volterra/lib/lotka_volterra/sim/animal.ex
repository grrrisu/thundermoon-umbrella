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
    {consumed_food, animal_size} =
      calculate_delta(
        size * animal.needed_food / animal.graze_rate <= producer_size,
        producer,
        animal
      )

    {Map.put(producer, :size, (producer_size - consumed_food * step) |> min_zero()),
     Map.put(animal, :size, size + animal_size * step)}
  end

  # enough food
  def calculate_delta(true, _producer, %{size: size} = animal) do
    growth = size * (animal.birth_rate - animal.death_rate)
    {size * animal.needed_food, growth}
  end

  # not enough food
  def calculate_delta(false, %{size: producer_size}, %{size: size} = animal) do
    needed_producers = size * animal.needed_food / animal.graze_rate

    starving_rate =
      animal.starving_rate * (needed_producers - producer_size) / needed_producers

    # consumed_food =
    #   producer_size * animal.graze_rate +
    #     (size * animal.needed_food - producer_size * animal.graze_rate) *
    #       (producer_size *
    #          animal.graze_rate) / (size * animal.needed_food)

    {producer_size * animal.graze_rate,
     size * (animal.birth_rate - animal.death_rate - starving_rate)}
  end

  def min_zero(n) when n < 0, do: 0
  def min_zero(n), do: n
end
