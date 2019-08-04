defmodule ThundermoonWeb.DashboardControllerTest do
  use ThundermoonWeb.ConnCase

  alias Thundermoon.Factory

  import ThundermoonWeb.AuthSupport

  test "get redirected if not logged in", %{conn: conn} do
    conn = get(conn, "/dashboard")
    assert redirected_to(conn) == "/"
  end

  test "get dashboard if logged in", %{conn: conn} do
    current_user = Factory.create(:user, %{username: "crumb"})
    conn = login_as(conn, current_user)

    conn = get(conn, "/dashboard")
    assert html_response(conn, 200) =~ "Welcome crumb!"
  end
end
