defmodule Thundermoon.LotkaVolterra.AnimalForm do
  use Thundermoon.FormData

  @types %{
    birth_rate: :float,
    death_rate: :float,
    needed_food: :integer,
    starving_rate: :float,
    graze_rate: :float,
    size: :integer
  }

  def changeset(%{} = model, params \\ %{}) do
    {model, @types}
    |> cast(params, [:birth_rate, :death_rate, :needed_food, :starving_rate, :graze_rate, :size])
    |> validate_required(:size)
    |> validate_number(:birth_rate, greater_than: 0)
    |> validate_number(:death_rate, greater_than: 0)
    |> validate_number(:needed_food, greater_than: 0)
    |> validate_number(:starving_rate, greater_than: 0)
    |> validate_number(:graze_rate, greater_than: 0)
    |> validate_number(:size, greater_than: 0)
    |> validate_greater_than(:birth_rate, :death_rate)
  end
end
