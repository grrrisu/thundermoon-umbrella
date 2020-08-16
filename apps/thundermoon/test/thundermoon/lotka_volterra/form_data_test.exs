defmodule Thundermoon.LotkaVolterra.FormDataTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset

  alias Thundermoon.LotkaVolterra.FormData
  alias LotkaVolterra.Vegetation

  describe "changeset" do
    test "set default values" do
      changeset = FormData.changeset(%Vegetation{})
      assert 650 == Changeset.get_field(changeset, :size)
    end

    test "overwrite values" do
      valid_params = %{capacity: 5000, birth_rate: 0.5, death_rate: 0.1, size: 800}
      changeset = FormData.changeset(%Vegetation{size: 650}, valid_params)
      assert 800 == Changeset.get_field(changeset, :size)
    end

    test "prevent invalid values" do
      changeset = FormData.changeset(%Vegetation{size: 650}, %{size: -50})
      refute changeset.valid?
      refute changeset.errors[:size] |> is_nil()
    end

    test "validate size smaller than capacity" do
      changeset = FormData.changeset(%Vegetation{}, %{capacity: 50, size: 500})
      refute changeset.valid?
      refute changeset.errors[:capacity] |> is_nil()
    end
  end

  describe "apply params" do
    test "valid" do
      assert {:ok, %Vegetation{} = vegetation} =
               FormData.apply_params(%Vegetation{}, %{size: 800})

      assert vegetation.size == 800
    end

    test "invalid" do
      assert {:error, %Changeset{} = changeset} =
               FormData.apply_params(%Vegetation{}, %{size: -50})

      assert -50 == Changeset.get_field(changeset, :size)
    end
  end
end
