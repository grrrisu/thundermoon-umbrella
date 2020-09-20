defmodule ThundermoonWeb.LotkaVolterraLive.NewTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest

  import ThundermoonWeb.AuthSupport

  def login_as_member(%{conn: conn}) do
    conn = login_as(conn, %{username: "crumb"})
    %{conn: conn}
  end

  describe "a guest" do
    test "should be redirected", %{conn: conn} do
      conn = get(conn, "/lotka-volterra/new")
      assert redirected_to(conn) == "/"
    end
  end

  describe "a member" do
    setup :login_as_member

    test "create a vegetation", %{conn: conn} do
      conn = get(conn, "/lotka-volterra/new")
      assert html_response(conn, 200) =~ "<h3>Vegetation</h3>"
      {:ok, view, html} = live(conn)
      assert html =~ "<h3>Vegetation</h3>"

      {:ok, _view, html} =
        view
        |> element("form")
        |> render_submit(%{
          "vegetation" => %{
            "capacity" => "6000",
            "birth_rate" => "0.2",
            "death_rate" => "0.1",
            "size" => "1000"
          }
        })
        |> follow_redirect(conn)

      assert html =~ "successfully created vegetation"
    end

    test "create a herbivore", %{conn: conn} do
      conn = get(conn, "/lotka-volterra/new")
      assert html_response(conn, 200) =~ "<h3>Vegetation</h3>"
      {:ok, view, html} = live(conn)

      assert view
             |> element("#button-add-herbivore")
             |> render_click() =~ "<h3>Herbivore</h3>"

      {:ok, _view, html} =
        view
        |> element("form")
        |> render_submit(%{
          "herbivore" => %{
            "birth_rate" => "0.2",
            "death_rate" => "0.1",
            "needed_food" => "4",
            "starving_rate" => "0.4",
            "graze_rate" => "0.01",
            "size" => "1000"
          }
        })
        |> follow_redirect(conn)

      assert html =~ "successfully created herbivore"
    end
  end
end
