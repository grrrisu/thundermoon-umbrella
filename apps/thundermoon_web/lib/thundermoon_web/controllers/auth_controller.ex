defmodule ThundermoonWeb.AuthController do
  use ThundermoonWeb, :controller

  plug Ueberauth

  alias ThundermoonWeb.AuthService
  alias Thundermoon.Accounts

  def integration(conn, %{"external_user_id" => id}) do
    if Mix.env() == :integration do
      case Accounts.find_by_external_id(id) do
        nil ->
          conn
          |> put_flash(:error, "no user found with external_user_id #{id}")
          |> redirect(to: "/")

        user ->
          conn
          |> put_session(:current_user_id, user.id)
          |> redirect(to: "/dashboard")
      end
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Authentification failed!")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case AuthService.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated as #{user.username}.")
        |> put_session(:current_user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: "/dashboard")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end
end
