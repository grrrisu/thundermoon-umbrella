defmodule ThundermoonWeb.Api.IntegrationController do
  use ThundermoonWeb, :controller

  alias Thundermoon.Accounts
  alias Thundermoon.GameOfLife

  def authorize(conn, %{"external_user_id" => id}) do
    case Accounts.find_by_external_id(id) do
      nil ->
        send_resp(conn, 404, "no user found with external_user_id #{id}")

      user ->
        conn
        |> fetch_session()
        |> put_session(:current_user_id, user.id)
        |> send_resp(201, "user session created")
    end
  end

  def clear_session(conn, _params) do
    conn
    |> fetch_session()
    |> clear_session()
    |> send_resp(205, "user session cleared")
  end

  def restart_game_of_life(conn, _params) do
    :ok = GameOfLife.recreate()
    send_resp(conn, 205, "game of life has been restarted")
  end

  def create_game_of_life(conn, %{"size" => size}) do
    {:ok, _pid} = GameOfLife.create(String.to_integer(size))
    send_resp(conn, 201, "grid created")
  end
end
