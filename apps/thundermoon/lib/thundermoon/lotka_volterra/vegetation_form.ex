defmodule Thundermoon.LotkaVolterra.VegetationForm do
  use Thundermoon.FormData

  alias LotkaVolterra.Vegetation

  @types %{
    capacity: :integer,
    birth_rate: :float,
    death_rate: :float,
    size: :integer
  }

  def changeset(%Vegetation{} = model, params \\ %{}) do
    {model, @types}
    |> cast(params, [:capacity, :birth_rate, :death_rate, :size])
    |> validate_required(:size)
    |> validate_number(:capacity, greater_than: 0)
    |> validate_number(:birth_rate, greater_than: 0)
    |> validate_number(:death_rate, greater_than: 0)
    |> validate_number(:size, greater_than: 0)
    |> validate_greater_than(:capacity, :size)
    |> validate_greater_than(:birth_rate, :death_rate)
  end
end
