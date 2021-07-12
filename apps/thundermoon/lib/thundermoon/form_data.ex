defmodule Thundermoon.FormData do
  defmacro __using__(_opts) do
    quote do
      import Ecto.Changeset

      def validate_greater_than(changeset, field, other, opts \\ []) do
        changeset
        |> validate_changed_greater_than(field, other, opts)
        |> validate_changed_smaller_than(other, field, opts)
      end

      defp validate_changed_greater_than(changeset, field, other, opts \\ []) do
        validate_change(changeset, field, fn _, value ->
          case value >= get_field(changeset, other) do
            true -> []
            false -> [{field, opts[:message] || "must be greater than #{other}"}]
          end
        end)
      end

      defp validate_changed_smaller_than(changeset, field, other, opts \\ []) do
        validate_change(changeset, field, fn _, value ->
          case value < get_field(changeset, other) do
            true -> []
            false -> [{field, opts[:message] || "must be smaller than #{other}"}]
          end
        end)
      end

      def apply_valid_changes(%Ecto.Changeset{valid?: false} = changeset) do
        {:error, Map.put(changeset, :action, :insert)}
      end

      def apply_valid_changes(%Ecto.Changeset{valid?: true} = changeset) do
        {:ok, apply_changes(changeset)}
      end
    end
  end
end
