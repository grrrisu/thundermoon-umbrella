defmodule Thundermoon.FormData do
  defmacro __using__(_opts) do
    quote do
      import Ecto.Changeset

      defdelegate apply_action(changeset, action), to: Ecto.Changeset

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

      # -------------------

      def load_attributes(model, %{} = attributes) do
        Enum.reduce(attributes, model, fn {attribute, type}, result ->
          value = Map.get(model, attribute)
          Map.put(result, attribute, load_attribute(value, type))
        end)
      end

      defp load_attribute(value, type) do
        case type.load(value) do
          {:ok, value} -> value
          :error -> raise "could not load for type #{type}"
        end
      end
    end
  end
end
