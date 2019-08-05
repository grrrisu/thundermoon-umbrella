defmodule ThundermoonWeb.AuthorizationHelpers do
  use ThundermoonWeb, :controller

  def handle_unauthorized(conn) do
    conn
    |> put_flash(:error, "You are not authorized to access this page!")
    |> redirect(to: "/")
    |> halt
  end

  def handle_not_found(conn) do
    conn
    |> put_status(404)
    |> halt
  end
end