defmodule ThundermoonWeb.LayoutView do
  use ThundermoonWeb, :view

  def signed_in?(conn) do
    Plug.Conn.get_session(conn, :current_user)
  end
end
