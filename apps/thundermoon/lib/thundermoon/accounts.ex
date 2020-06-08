defmodule Thundermoon.Accounts do
  import Ecto.Query, warn: false

  alias Ecto.Changeset

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  def count() do
    Repo.aggregate(User, :count, :id)
  end

  def all_users do
    Repo.all(User)
  end

  def get_user(id) do
    Repo.get!(User, id)
  end

  def user_changeset(id) do
    User
    |> Repo.get(id)
    |> Changeset.change()
  end

  def update_user(id, params) do
    User
    |> Repo.get(id)
    |> User.update_changeset(params)
    |> Repo.update()
  end

  def create_user(params \\ {}) do
    %User{}
    |> User.create_changeset(params)
    |> Repo.insert()
  end

  def create_member(params) do
    member_params = Map.merge(params, %{role: "member"})
    create_user(member_params)
  end

  def find_or_create(%{external_id: external_id} = params) do
    case find_by_external_id(external_id) do
      %User{} = user -> {:ok, user}
      nil -> create_member(params)
    end
  end

  def find_by_external_id(external_id) do
    User
    |> where(external_id: ^external_id)
    |> Repo.one()
  end

  def destroy_user(id) do
    User
    |> Repo.get!(id)
    |> Repo.delete()
  end
end
