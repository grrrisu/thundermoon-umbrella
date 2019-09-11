defmodule ThundermoonWeb.CounterLiveTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest
  @endpoint ThundermoonWeb.Endpoint

  import ThundermoonWeb.AuthSupport

  alias Thundermoon.CounterRealm

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
      CounterRealm.reset()
    end

    test "inc digit 10", %{conn: conn} do
      @endpoint.subscribe("counter")
      {:ok, view, _html} = live(conn, "/counter")
      render_click(view, :inc, "10")
      assert_receive(%{event: "update", payload: %{digit_10: 1,}})
      CounterRealm.reset()
    end

    test "dec digit 10", %{conn: conn} do
      @endpoint.subscribe("counter")
      {:ok, view, _html} = live(conn, "/counter")
      render_click(view, :inc, "10")
      assert_receive(%{event: "update", payload: %{digit_10: 1,}})
      render_click(view, :dec, "10")
      assert_receive(%{event: "update", payload: %{digit_10: 0,}})
      CounterRealm.reset()
    end

    # test "sees users", %{conn: conn} do
    #   {:ok, _view, html} = live(conn, "/counter")
    #   assert html =~ "<div class=\"user\">crumb</div>"
    # end

    # test "can not clear messages", %{conn: conn} do
    #   ChatMessages.add(%{user: "franquin", text: "Bonjour"})
    #   {:ok, view, html} = live(conn, "/counter")
    #   assert html =~ "Bonjour"
    #   render_click(view, :clear)
    #   conn = get(conn, "/counter")
    #   assert html_response(conn, 200) =~ "Bonjour"
    #   ChatMessages.clear()
    # end
  end

  # describe "an admin" do
  #   setup [:login_as_admin]

  #   test "can clear all messages", %{conn: conn} do
  #     ChatMessages.add(%{user: "franquin", text: "Bonjour"})
  #     {:ok, view, html} = live(conn, "/counter")
  #     assert html =~ "Bonjour"
  #     render_click(view, :clear)
  #     conn = get(conn, "/counter")
  #     refute html_response(conn, 200) =~ "Bonjour"
  #     ChatMessages.clear()
  #   end
  # end
end
