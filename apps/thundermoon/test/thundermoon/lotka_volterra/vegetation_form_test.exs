defmodule Thundermoon.LotkaVolterra.VegetationFormTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset

  alias Thundermoon.LotkaVolterra.VegetationForm
  alias LotkaVolterra.Vegetation

  describe "changeset" do
    test "set default values" do
      changeset = VegetationForm.changeset(%Vegetation{})
      assert 650 == Changeset.get_field(changeset, :size)
    end

    test "overwrite values" do
      valid_params = %{capacity: 5000, birth_rate: 0.5, death_rate: 0.1, size: 800}
      changeset = VegetationForm.changeset(%Vegetation{size: 650}, valid_params)
      assert 800 == Changeset.get_field(changeset, :size)
    end

    test "prevent invalid values" do
      changeset = VegetationForm.changeset(%Vegetation{size: 650}, %{size: -50})
      refute changeset.valid?
      refute changeset.errors[:size] |> is_nil()
    end

    test "validate size smaller than capacity" do
      changeset = VegetationForm.changeset(%Vegetation{}, %{capacity: 50, size: 500})
      refute changeset.valid?
      refute changeset.errors[:capacity] |> is_nil()
    end
  end

  describe "apply valid changes" do
    test "valid" do
      changeset = VegetationForm.changeset(%Vegetation{}, %{size: 800})
      assert {:ok, %Vegetation{}} = VegetationForm.apply_valid_changes(changeset)
    end

    test "invalid" do
      changeset = VegetationForm.changeset(%Vegetation{}, %{size: -50})
      assert {:error, %Changeset{} = changeset} = VegetationForm.apply_valid_changes(changeset)
      assert -50 == Changeset.get_field(changeset, :size)
    end
  end
end
