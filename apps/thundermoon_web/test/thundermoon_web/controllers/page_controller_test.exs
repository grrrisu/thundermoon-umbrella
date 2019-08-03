defmodule ThundermoonWeb.PageControllerTest do
  use ThundermoonWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Thundermoon!"
  end
end
