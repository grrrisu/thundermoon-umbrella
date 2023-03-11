defmodule ThundermoonWeb.UserControllerTest do
  use ThundermoonWeb.ConnCase

  alias Thundermoon.Factory
  alias ThundermoonWeb.AuthSupport

  setup(_) do
    users = [
      Factory.create(:user, external_id: 123, username: "robert_crumb"),
      Factory.create(:user, external_id: 456, username: "gilbert_shelton", role: "admin")
    ]

    %{users: users}
  end

  describe "as guest" do
    test "show users list", %{conn: conn} do
      conn = get(conn, "/users")
      assert redirected_to(conn) == "/"
    end

    test "edit a user", %{conn: conn, users: users} do
      conn = get(conn, "/users/#{List.first(users).id}/edit")
      assert redirected_to(conn) == "/"
    end

    test "update a user", %{conn: conn, users: users} do
      conn = put(conn, "/users/#{List.first(users).id}", %{"user" => %{"username" => "foo"}})
      assert redirected_to(conn) == "/"
    end
  end

  describe "as member" do
    setup(%{conn: conn, users: users}) do
      new_conn = AuthSupport.login_as(conn, List.first(users))
      %{conn: new_conn}
    end

    test "show users list", %{conn: conn} do
      conn = get(conn, "/users")
      assert html_response(conn, 200) =~ "robert_crumb"
    end

    test "edit my own user", %{conn: conn, users: users} do
      conn = get(conn, "/users/#{List.first(users).id}/edit")
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "update my own user", %{conn: conn, users: users} do
      conn = put(conn, "/users/#{List.first(users).id}", %{"user" => %{"username" => "foo"}})
      assert conn.assigns.flash["info"] == "User has been updated"
      assert redirected_to(conn) == "/users"
    end

    test "edit another user", %{conn: conn, users: users} do
      conn = get(conn, "/users/#{List.last(users).id}/edit")
      assert redirected_to(conn) == "/"
    end

    test "update another user", %{conn: conn, users: users} do
      conn = put(conn, "/users/#{List.last(users).id}", %{"user" => %{"username" => "foo"}})
      assert redirected_to(conn) == "/"
    end

    test "delete another user", %{conn: conn, users: users} do
      conn = delete(conn, "/users/#{List.last(users).id}")
      assert redirected_to(conn) == "/"
    end
  end

  describe "as admin" do
    setup(%{conn: conn, users: users}) do
      new_conn = AuthSupport.login_as(conn, List.last(users))
      %{conn: new_conn}
    end

    test "show users list", %{conn: conn} do
      conn = get(conn, "/users")
      assert html_response(conn, 200) =~ "robert_crumb"
    end

    test "edit another user", %{conn: conn, users: users} do
      conn = get(conn, "/users/#{List.first(users).id}/edit")
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "update another user", %{conn: conn, users: users} do
      conn = put(conn, "/users/#{List.first(users).id}", %{"user" => %{"username" => "foo"}})
      assert conn.assigns.flash["info"] == "User has been updated"
      assert redirected_to(conn) == "/users"
    end

    test "delete own user", %{conn: conn, users: users} do
      conn = delete(conn, "/users/#{List.last(users).id}")
      assert conn.assigns.flash["error"] == "You are not authorized to access this page!"
      assert redirected_to(conn) == "/"
    end

    test "delete another user", %{conn: conn, users: users} do
      conn = delete(conn, "/users/#{List.first(users).id}")
      assert conn.assigns.flash["info"] == "User has been deleted"
      assert redirected_to(conn) == "/users"
    end
  end
end
