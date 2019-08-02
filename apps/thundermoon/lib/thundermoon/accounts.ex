defmodule Thundermoon.Accounts do
  import Ecto.Query, warn: false

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  def create_user(params \\ {}) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end
end
