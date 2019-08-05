defmodule ThundermoonWeb.UserController do
  use ThundermoonWeb, :controller

  alias Thundermoon.Accounts

  def index(conn, _params) do
    users = Accounts.all_users()
    render(conn, "index.html", users: users)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.user_changeset(id)
    render(conn, "edit.html", user: user)
  end
end
