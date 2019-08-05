defmodule Thundermoon.Accounts.User do
  import Ecto.Changeset
  use Ecto.Schema

  schema "users" do
    field :external_id, :integer
    field :username, :string
    field :name, :string
    field :email, :string
    field :role, :string, default: "member"
    field :avatar, :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :email, :role, :name, :external_id, :avatar])
    |> validate_required([:username, :role, :external_id])
    |> validate_format(:email, ~r/^[^@]+@([^@\.]+\.)+[^@\.]+$/)
    |> validate_inclusion(:role, ["member", "admin"])
    |> unique_constraint(:external_id)
  end
end
