defmodule GameOfLife.FormData do
  use Thundermoon.FormData

  defstruct size: nil

  @types %{
    size: :integer
  }

  def changeset(model, params \\ %{}) do
    {model, @types}
    |> cast(params, [:size])
    |> validate_required(:size)
    |> validate_number(:size, greater_than: 0, less_than_or_equal_to: 100)
  end
end
