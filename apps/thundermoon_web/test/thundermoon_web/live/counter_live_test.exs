defmodule ThundermoonWeb.CounterLiveTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest

  import ThundermoonWeb.AuthSupport

  alias Phoenix.PubSub

  alias Thundermoon.Counter

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
      conn = get(conn, "/counter")
      assert redirected_to(conn) == "/"
    end
  end

  describe "a member" do
    setup [:login_as_member]

    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/counter")
      assert html_response(conn, 200) =~ "<h1>Counter</h1>"
      {:ok, _view, html} = live(conn)
      assert html =~ "<h1>Counter</h1>"
      Counter.reset()
    end

    test "inc digit 10", %{conn: conn} do
      PubSub.subscribe(ThundermoonWeb.PubSub, "counter")
      {:ok, view, _html} = live(conn, "/counter")
      view |> element("#digit-10-inc") |> render_click()
      assert_receive({:update, %{digit_10: 1}})
      Counter.reset()
    end

    test "dec digit 10", %{conn: conn} do
      PubSub.subscribe(ThundermoonWeb.PubSub, "counter")
      {:ok, view, _html} = live(conn, "/counter")
      view |> element("#digit-10-inc") |> render_click()
      assert_receive({:update, %{digit_10: 1}})
      view |> element("#digit-10-dec") |> render_click()
      assert_receive({:update, %{digit_10: 0}})
      Counter.reset()
    end

    test "can not reset the counter", %{conn: conn} do
      {:ok, view, html} = live(conn, "/counter")
      refute html =~ "reset"

      render_click(view, :reset)
      assert_redirect(view, "/")
    end

    test "can start and stop sim", %{conn: conn} do
      PubSub.subscribe(ThundermoonWeb.PubSub, "counter")
      {:ok, view, _html} = live(conn, "/counter")
      view |> element("#start-button") |> render_click()
      assert_receive({:sim, started: true})
      view |> element("#start-button") |> render_click()
      assert_receive({:sim, started: false})
    end
  end

  describe "an admin" do
    setup [:login_as_admin]

    test "can reset the counter", %{conn: conn} do
      PubSub.subscribe(ThundermoonWeb.PubSub, "counter")
      {:ok, view, html} = live(conn, "/counter")
      assert html =~ "reset"
      render_click(view, :reset)
      assert_receive({:update, %{digit_1: 0}})
      assert_receive({:update, %{digit_10: 0}})
      assert_receive({:update, %{digit_100: 0}})
    end
  end
end
