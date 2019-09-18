defmodule ThundermoonWeb.AuthPlug do
  import Plug.Conn

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

      true ->
        conn
        |> assign(:current_user, nil)
    end
  end
end
