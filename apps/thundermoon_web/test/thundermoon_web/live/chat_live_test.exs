defmodule ThundermoonWeb.ChatLiveTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  import ThundermoonWeb.AuthSupport

  alias Thundermoon.ChatMessages

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
      conn = get(conn, "/chat")
      assert redirected_to(conn) == "/"
    end
  end

  describe "a member" do
    setup [:login_as_member]

    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/chat")
      assert html_response(conn, 200) =~ "<h1>Chat</h1>"
      {:ok, _view, html} = live(conn)
      assert html =~ "<h1>Chat</h1>"
    end

    test "sends a message", %{conn: conn} do
      PubSub.subscribe(ThundermoonWeb.PubSub, "chat")
      {:ok, view, _html} = live(conn, "/chat")
      data = %{"message" => %{"text" => "hello there"}}
      render_submit(view, :send, data)
      assert_receive({:send, %{user: "crumb", text: "hello there"}})
    end

    test "sees users", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/chat")
      assert html =~ "<div class=\"user\">crumb</div>"
    end

    test "can not clear messages", %{conn: conn} do
      ChatMessages.add(%{user: "franquin", text: "Bonjour"})
      {:ok, view, html} = live(conn, "/chat")
      assert html =~ "Bonjour"
      render_click(view, :clear)
      conn = get(conn, "/chat")
      assert html_response(conn, 200) =~ "Bonjour"
      ChatMessages.clear()
    end
  end

  describe "an admin" do
    setup [:login_as_admin]

    test "can clear all messages", %{conn: conn} do
      ChatMessages.add(%{user: "franquin", text: "Bonjour"})
      {:ok, view, html} = live(conn, "/chat")
      assert html =~ "Bonjour"
      render_click(view, :clear)
      conn = get(conn, "/chat")
      refute html_response(conn, 200) =~ "Bonjour"
      ChatMessages.clear()
    end
  end
end
