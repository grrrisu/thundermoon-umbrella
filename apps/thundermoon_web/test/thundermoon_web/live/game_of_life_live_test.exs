defmodule ThundermoonWeb.GameOfLifeLiveTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest
  @endpoint ThundermoonWeb.Endpoint

  import ThundermoonWeb.AuthSupport

  def login_as_member(%{conn: conn}) do
    conn = login_as(conn, %{username: "crumb"})
    %{conn: conn}
  end

  describe "a guest" do
    test "should be redirected", %{conn: conn} do
      conn = get(conn, "/game_of_life")
      assert redirected_to(conn) == "/"
    end
  end

  describe "a member" do
    setup [:login_as_member]

    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/game_of_life")
      assert html_response(conn, 200) =~ "<h1>Game of Life</h1>"
      {:ok, _view, html} = live(conn)
      assert html =~ "<h1>Game of Life</h1>"
    end
  end
end
