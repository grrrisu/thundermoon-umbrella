defmodule LotkaVolterra.Vegetation do
  alias LotkaVolterra.Vegetation

  defstruct capacity: 1300,
            birth_rate: 0.15,
            death_rate: 0.05,
            size: 650

  # vegetation grows by birth rate (alias grow rate) and shrinks by natural deaths (age),
  # the vegetation size is limited by the capacity (available room, sun energy)
  #
  # b : birth_rate
  # d : death_rate
  # C : capacity
  # s : size
  #
  # Δ &#916;
  #
  #                (C - s)
  # Δs = s (b - d) -------
  #                  C
  def delta(%Vegetation{
        capacity: capacity,
        birth_rate: birth_rate,
        death_rate: death_rate,
        size: size
      }) do
    size * (birth_rate - death_rate) * (capacity - size) / capacity
  end

  def sim(%Vegetation{size: size} = vegetation, step \\ 1) do
    new_size = size + delta(vegetation) * step
    %Vegetation{vegetation | size: new_size}
  end
end
