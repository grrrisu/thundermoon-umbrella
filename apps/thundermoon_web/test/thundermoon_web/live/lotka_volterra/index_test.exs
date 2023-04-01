defmodule ThundermoonWeb.LotkaVolterraLive.IndexTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest

  import ThundermoonWeb.AuthSupport

  def login_as_member(%{conn: conn}) do
    conn = login_as(conn, %{username: "crumb"})
    %{conn: conn}
  end

  def create_sim(_) do
    {sim_id, _obj} = LotkaVolterra.create(nil, ThundermoonWeb.PubSub)
    %{sim_id: sim_id}
  end

  describe "a guest" do
    test "should be redirected", %{conn: conn} do
      conn = get(conn, "/lotka-volterra")
      assert redirected_to(conn) == "/"
    end
  end

  describe "a member" do
    setup [:login_as_member, :create_sim]

    test "redirected if sim_id does not exists", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/lotka-volterra/new"}}} =
               live(conn, "/lotka-volterra?sim_id=555")
    end

    test "disconnected and connected mount", %{conn: conn, sim_id: sim_id} do
      conn = get(conn, "/lotka-volterra?sim_id=" <> sim_id)
      assert html_response(conn, 200) =~ "Lotka Volterra"
      {:ok, view, _html} = live(conn)
      has_element?(view, "h1", "Lotka Volterra")
    end
  end
end
