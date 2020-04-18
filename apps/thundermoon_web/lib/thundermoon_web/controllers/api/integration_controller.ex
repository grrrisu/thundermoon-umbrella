defmodule ThundermoonWeb.Api.IntegrationController do
  use ThundermoonWeb, :controller

  alias Thundermoon.Accounts
  alias Thundermoon.GameOfLife

  def authorize(conn, %{"external_user_id" => id}) do
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

  def restart_game_of_life(conn, _params) do
    :ok = GameOfLife.restart()
    send_resp(conn, 205, "game of life has been restarted")
  end

  def create_game_of_life(conn, %{"size" => size}) do
    {:ok, _pid} = GameOfLife.create(String.to_integer(size))
    send_resp(conn, 201, "grid created")
  end
end
