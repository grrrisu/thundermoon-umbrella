defmodule ThundermoonWeb.ChatControllerTest do
  use ThundermoonWeb.ConnCase

  alias Thundermoon.Factory
  alias ThundermoonWeb.AuthSupport
  alias ThundermoonWeb.ChatMessages

  setup(_) do
    message = %{user: "franquin", text: "Bonjour!"}
    ChatMessages.add(message)

    users = [
      Factory.create(:user, external_id: 123, username: "robert_crumb"),
      Factory.create(:user, external_id: 456, username: "gilbert_shelton", role: "admin")
    ]

    %{users: users}
  end

  describe "as guest" do
    test "I can not delete messages", %{conn: conn} do
      conn = delete(conn, "/chat")
      assert redirected_to(conn) == "/"
    end
  end

  describe "as member" do
    setup(%{conn: conn, users: users}) do
      new_conn = AuthSupport.login_as(conn, List.first(users))
      %{conn: new_conn}
    end

    test "I can not delete messages", %{conn: conn} do
      conn = delete(conn, "/chat")
      assert redirected_to(conn) == "/"
      conn = get(conn, "/chat")
      assert html_response(conn, 200) =~ "Bonjour!"
    end
  end

  describe "as admin" do
    setup(%{conn: conn, users: users}) do
      new_conn = AuthSupport.login_as(conn, List.last(users))
      %{conn: new_conn}
    end

    test "I can delete all messages", %{conn: conn} do
      conn = delete(conn, "/chat")
      assert redirected_to(conn) == "/chat"
      conn = get(conn, "/chat")
      refute html_response(conn, 200) =~ "Bonjour!"
    end
  end
end
