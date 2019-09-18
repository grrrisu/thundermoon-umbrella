defmodule ThundermoonWeb.MemberareaPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  def init(_params) do
  end

  def call(conn, _params) do
    case conn.assigns.current_user do
      nil ->
        conn
        |> halt
        |> put_flash(:error, "Not authorized! Please login first.")
        |> redirect(to: "/")

      _user ->
        conn
    end
  end
end
