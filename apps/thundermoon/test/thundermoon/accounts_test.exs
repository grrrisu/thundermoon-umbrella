defmodule Thundermoon.AccountsTest do
  use Thundermoon.DataCase

  alias Thundermoon.Accounts
  alias Thundermoon.Factory

  def setup_users do
    Factory.create(:user, %{external_id: 789, username: "art_spiegelman"})
  end

  test "create a member" do
    {:ok, user} =
      Accounts.create_user(%{
        external_id: 123,
        username: "robert_crumb",
        email: "robert@crumb.com"
      })

    assert "robert_crumb" == user.username
    assert "robert@crumb.com" == user.email
    assert "member" == user.role
  end

  test "create a admin" do
    {:ok, user} =
      Accounts.create_user(%{
        external_id: 456,
        username: "gilbert_shelton",
        email: "gilbert@shelton.com",
        role: "admin"
      })

    assert "gilbert_shelton" == user.username
    assert "gilbert@shelton.com" == user.email
    assert "admin" == user.role
  end

  test "force create member" do
    {:ok, user} =
      Accounts.create_member(%{
        external_id: 123,
        username: "robert_crumb",
        role: "admin"
      })

    assert "robert_crumb" == user.username
    assert "member" == user.role
  end

  test "find by external_id" do
    setup_users()

    user = Accounts.find_by_external_id(789)
    assert 789 == user.external_id
  end

  test "return authenticated user from db" do
    db_user = setup_users()

    {:ok, user} = Accounts.find_or_create(%{external_id: 789, username: "arthur_spiegelman"})
    assert db_user.id == user.id
    assert user.username == "art_spiegelman"
  end

  test "create authenticated user" do
    setup_users()

    refute Accounts.find_by_external_id(007)
    {:ok, user} = Accounts.find_or_create(%{external_id: 007, username: "another_spiegelman"})
    assert Accounts.find_by_external_id(007)
    assert "another_spiegelman" == user.username
  end

  test "update user" do
    user = setup_users()

    {:ok, updated_user} = Accounts.update_user(user.id, %{username: "king_arthur"})
    assert "king_arthur", updated_user.username
  end

  test "delete user" do
    user = setup_users()

    assert {:ok, deleted_user} = Accounts.destroy_user(user.id)

    assert_raise Ecto.NoResultsError, fn ->
      Accounts.destroy_user(user.id)
    end
  end
end
