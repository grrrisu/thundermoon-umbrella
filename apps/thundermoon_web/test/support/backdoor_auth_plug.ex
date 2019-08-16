defmodule ThundermoonWeb.BackdoorAuthPlug do
  import Plug.Conn

  def init(_opts) do
  end

  def call(%Plug.Conn{params: params} = conn, _opts) do
    case params["current_user_id"] do
      nil -> conn
      user_id -> put_session(conn, :current_user_id, user_id)
    end
  end
end
