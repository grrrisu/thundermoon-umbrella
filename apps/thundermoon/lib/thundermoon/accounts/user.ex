defmodule Thundermoon.Accounts.User do
  import Ecto.Changeset
  use Ecto.Schema

  schema "users" do
    field :username, :string
    field :email, :string
    field(:role, :string, default: "member")

    timestamps()
  end

  def changeset(user, params \\ {}) do
    user
    |> cast(params, [:username, :email, :role])
    |> validate_required([:username, :email, :role])
    |> validate_format(:email, ~r/^[^@]+@([^@\.]+\.)+[^@\.]+$/)
    |> validate_inclusion(:role, ["member", "admin"])
  end
end
