defmodule ThundermoonWeb.PageController do
  use ThundermoonWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
