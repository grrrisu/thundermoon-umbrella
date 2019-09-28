defmodule ThundermoonWeb.GameOfLifeLiveTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest
  @endpoint ThundermoonWeb.Endpoint

  import ThundermoonWeb.AuthSupport

  alias Thundermoon.GameOfLife

  def login_as_member(%{conn: conn}) do
    conn = login_as(conn, %{username: "crumb"})
    %{conn: conn}
  end

  def login_as_admin(%{conn: conn}) do
    conn = login_as(conn, %{username: "gilbert_shelton", role: "admin"})
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

    test "can not create a grid", %{conn: conn} do
      {:ok, view, html} = live(conn, "/game_of_life")
      assert html =~ "no simulation available"

      data = %{"grid" => %{"size" => "5"}}

      assert_redirect(view, "/", fn ->
        render_submit(view, :create, data)
      end)
    end

    test "can start and stop sim", %{conn: conn} do
      GameOfLife.create(3)
      @endpoint.subscribe("Thundermoon.GameOfLife")
      {:ok, view, _html} = live(conn, "/game_of_life")
      render_click(view, "toggle-sim-start", %{"action" => "start"})
      assert_receive(%{event: "sim", payload: %{started: true}})
      render_click(view, "toggle-sim-start", %{"action" => "stop"})
      assert_receive(%{event: "sim", payload: %{started: false}})
      GameOfLife.recreate()
    end

    test "can reset the grid", %{conn: conn} do
      GameOfLife.create(3)
      @endpoint.subscribe("Thundermoon.GameOfLife")
      {:ok, view, _html} = live(conn, "/game_of_life")
      render_click(view, "toggle-sim-start", %{"action" => "start"})
      assert_receive(%{event: "sim", payload: %{started: true}})
      render_click(view, :restart)
      assert_receive(%{event: "sim", payload: %{started: false}})
      assert_receive(%{event: "update", payload: %{grid: %{}}})
      GameOfLife.recreate()
    end

    test "can clear the grid", %{conn: conn} do
      GameOfLife.create(3)
      @endpoint.subscribe("Thundermoon.GameOfLife")
      {:ok, view, _html} = live(conn, "/game_of_life")
      render_click(view, :clear)
      assert_receive(%{event: "update", payload: %{grid: %{0 => %{0 => false}}}})
      GameOfLife.recreate()
    end

    test "can not recreate a grid", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/game_of_life")

      assert_redirect(view, "/", fn ->
        render_click(view, :recreate)
      end)
    end
  end

  describe "a admin" do
    setup [:login_as_admin]

    test "can create a grid", %{conn: conn} do
      @endpoint.subscribe("Thundermoon.GameOfLife")
      {:ok, view, _html} = live(conn, "/game_of_life")

      data = %{"grid" => %{"size" => "5"}}
      render_submit(view, :create, data)
      assert_receive(%{event: "update", payload: %{grid: %{}}})
      GameOfLife.recreate()
    end

    test "can recreate a grid", %{conn: conn} do
      GameOfLife.create(3)
      {:ok, view, html} = live(conn, "/game_of_life")
      assert html =~ "id=\"grid\""
      render_click(view, "toggle-sim-start", %{"action" => "start"})
      render_click(view, :recreate)
      {:ok, _view, html} = live(conn, "/game_of_life")
      assert html =~ "Create a new Grid"
    end
  end
end
