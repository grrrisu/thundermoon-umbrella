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

      # https://github.com/phoenixframework/phoenix_live_view/blob/v0.14.7/lib/phoenix_live_view/test/live_view_test.ex#L1009
      # assert_redirect -> assert_navigation
      assert_receive {_ref, {:redirect, _topic, %{to: to}}}
      assert to =~ "/lotka-volterra?sim_id="
    end

    test "create a herbivore", %{conn: conn} do
      conn = get(conn, "/lotka-volterra/new")
      assert html_response(conn, 200) =~ "<h3>Vegetation</h3>"
      {:ok, view, _html} = live(conn)

      view
      |> element("#button-add-herbivore")
      |> render_click()

      assert render(view) =~ "<h3>Herbivore</h3>"

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

      assert_receive {_ref, {:redirect, _topic, %{to: to}}}
      assert to =~ "/lotka-volterra?sim_id="
    end

    test "create a predator", %{conn: conn} do
      conn = get(conn, "/lotka-volterra/new")
      assert html_response(conn, 200) =~ "<h3>Vegetation</h3>"
      {:ok, view, _html} = live(conn)

      view
      |> element("#button-add-herbivore")
      |> render_click()

      view
      |> element("#button-add-predator")
      |> render_click()

      assert render(view) =~ "<h3>Predator</h3>"

      view
      |> element("form")
      |> render_submit(%{
        "herbivore" => %{
          "birth_rate" => "0.4",
          "death_rate" => "0.1",
          "needed_food" => "2",
          "starving_rate" => "0.6",
          "graze_rate" => "0.1",
          "size" => "10"
        }
      })

      assert_receive {_ref, {:redirect, _topic, %{to: to}}}
      assert to =~ "/lotka-volterra?sim_id="
    end
  end
end
