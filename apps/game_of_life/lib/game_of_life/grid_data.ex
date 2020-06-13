defmodule GameOfLife.GridData do
  import Ecto.Changeset
  use Ecto.Schema

  schema("") do
    field(:size, :integer, virtual: true)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:size])
    |> validate_required(:size)
    |> validate_number(:size, greater_than: 0, less_than: 51)
  end
end
