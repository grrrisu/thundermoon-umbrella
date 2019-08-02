defmodule Thundermoon.AccountsTest do
  use Thundermoon.DataCase

  alias Thundermoon.Accounts

  test "create a member" do
    {:ok, user} =
      Accounts.create_user(%{
        username: "robert_crumb",
        email: "robert@crumb.com"
      })

    assert "robert_crumb" = user.username
    assert "robert@crumb.com" = user.email
    assert "member" = user.role
  end

  test "create a admin" do
    {:ok, user} =
      Accounts.create_user(%{
        username: "gilbert_shelton",
        email: "gilbert@shelton.com",
        role: "admin"
      })

    assert "gilbert_shelton" = user.username
    assert "gilbert@shelton.com" = user.email
    assert "admin" = user.role
  end
end
