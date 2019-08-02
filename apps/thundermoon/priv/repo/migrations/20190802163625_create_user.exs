defmodule Thundermoon.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table("users") do
      add :username, :string, default: false
      add :email, :string, default: false
      add :role, :string

      timestamps()
    end
  end
end
