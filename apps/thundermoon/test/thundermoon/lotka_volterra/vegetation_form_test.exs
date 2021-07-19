defmodule Thundermoon.LotkaVolterra.VegetationFormDataTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset

  alias Thundermoon.LotkaVolterra.VegetationFormData
  alias LotkaVolterra.Vegetation

  describe "changeset" do
    test "set default values" do
      changeset = VegetationFormData.changeset(%Vegetation{})
      assert 650 == Changeset.get_field(changeset, :size)
    end

    test "load values" do
      changeset = VegetationFormData.changeset(%Vegetation{size: 333.666})
      assert 333 == Changeset.get_field(changeset, :size)
    end

    test "overwrite values" do
      valid_params = %{capacity: 5000, birth_rate: 0.5, death_rate: 0.1, size: 800}
      changeset = VegetationFormData.changeset(%Vegetation{size: 650}, valid_params)
      assert 800 == Changeset.get_field(changeset, :size)
    end

    test "prevent invalid values" do
      changeset = VegetationFormData.changeset(%Vegetation{size: 650}, %{size: -50})
      refute changeset.valid?
      refute changeset.errors[:size] |> is_nil()
    end

    test "validate size smaller than capacity" do
      changeset = VegetationFormData.changeset(%Vegetation{}, %{capacity: 50, size: 500})
      refute changeset.valid?
      refute changeset.errors[:capacity] |> is_nil()
    end
  end

  describe "apply valid changes" do
    test "valid" do
      changeset = VegetationFormData.changeset(%Vegetation{}, %{size: 800})
      assert {:ok, %Vegetation{}} = VegetationFormData.apply_action(changeset, :update)
    end

    test "invalid" do
      changeset = VegetationFormData.changeset(%Vegetation{}, %{size: -50})

      assert {:error, %Changeset{} = changeset} =
               VegetationFormData.apply_action(changeset, :update)

      assert -50 == Changeset.get_field(changeset, :size)
    end
  end
end
