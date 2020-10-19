defmodule Thundermoon.LotkaVolterra.HerbivoreForm do
  import Ecto.Changeset

  alias Ecto.Changeset

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

  def validate_greater_than(changeset, field, other, opts \\ []) do
    validate_change(changeset, field, fn _, value ->
      case value >= Changeset.get_field(changeset, other) do
        true -> []
        false -> [{field, opts[:message] || "must be greater than #{other}"}]
      end
    end)
  end

  def apply_valid_changes(%Changeset{valid?: false} = changeset), do: {:error, changeset}

  def apply_valid_changes(%Changeset{valid?: true} = changeset) do
    {:ok, Changeset.apply_changes(changeset)}
  end
end
