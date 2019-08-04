defmodule Thundermoon.Repo.Migrations.AddExternalIdToUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :external_id, :integer
      add :name, :string
      add :avatar, :string
    end

    create unique_index("users", :external_id)
  end
end
