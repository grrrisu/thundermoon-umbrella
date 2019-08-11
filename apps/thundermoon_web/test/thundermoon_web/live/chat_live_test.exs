defmodule ThundermoonWeb.ChatLiveTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest
  @endpoint ThundermoonWeb.Endpoint

  import ThundermoonWeb.AuthSupport

  def login(%{conn: conn}) do
    conn = login_as(conn, %{username: "crumb"})
    %{conn: conn}
  end

  describe "a guest" do
    test "should be redirected", %{conn: conn} do
      conn = get(conn, "/chat")
      assert redirected_to(conn) == "/"
    end
  end

  describe "a member" do
    setup [:login]

    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/chat")
      assert html_response(conn, 200) =~ "<h1>Chat</h1>"
      {:ok, _view, html} = live(conn)
      assert html =~ "<h1>Chat</h1>"
    end

    test "sends a message", %{conn: conn} do
      @endpoint.subscribe("chat")
      {:ok, view, _html} = live(conn, "/chat")
      data = %{"message" => %{"text" => "hello there"}}
      render_submit(view, :send, data)
      assert_receive(%{event: "send", payload: %{user: "crumb", text: "hello there"}})
    end
  end
end
