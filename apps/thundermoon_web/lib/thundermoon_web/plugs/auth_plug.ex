defmodule ThundermoonWeb.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)

    cond do
      user = user_id && Repo.get(User, user_id) ->
        conn
        |> assign(:current_user, user)
        |> assign(:signed_in, true)

      true ->
        conn
        |> assign(:current_user, nil)
        |> assign(:signed_in, false)
        |> halt
        |> put_flash(:error, "Not authorized! Please login first.")
        |> redirect(to: "/")
    end
  end
end
