defmodule Thundermoon.Factory do
  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  def build(:user) do
    %User{external_id: 123, username: "foobar"}
  end

  def build(factory_name, attributes) do
    factory_name
    |> build
    |> struct(attributes)
  end

  def create(factory_name, attributes) do
    factory_name
    |> build(attributes)
    |> Repo.insert!()
  end
end
