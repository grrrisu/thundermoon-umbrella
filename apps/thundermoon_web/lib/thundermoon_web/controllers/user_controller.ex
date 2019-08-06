defmodule ThundermoonWeb.UserController do
  use ThundermoonWeb, :controller

  alias Thundermoon.Accounts

  plug :load_and_authorize_resource, model: Thundermoon.Accounts.User

  def index(conn, _params) do
    users = Accounts.all_users()
    render(conn, "index.html", users: users)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.user_changeset(id)
    render(conn, "edit.html", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case Accounts.update_user(id, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User has been updated")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Updating user has failed!")
        |> render("edit.html", user: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    conn =
      case Accounts.destroy_user(id) do
        {:ok, _user} ->
          put_flash(conn, :info, "User has been deleted")

        {:error, _changeset} ->
          put_flash(conn, :error, "Deleting user has failed!")
      end

    redirect(conn, to: Routes.user_path(conn, :index))
  end
end
