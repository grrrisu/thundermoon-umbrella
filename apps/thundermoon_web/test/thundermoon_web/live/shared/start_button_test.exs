defmodule ThundermoonWeb.Component.StartButtonTest do
  use ThundermoonWeb.ConnCase
  import Phoenix.LiveViewTest

  import ThundermoonWeb.AuthSupport

  setup(%{conn: conn}) do
    conn = login_as(conn, %{username: "crumb"})
    {sim_id, _obj} = LotkaVolterra.create(nil, ThundermoonWeb.PubSub)

    {:ok, view, html} = live(conn, Routes.lotka_volterra_index_path(conn, :index, sim_id: sim_id))

    %{view: view, html: html}
  end

  test "click start", %{view: view} do
    assert view |> element("#start-button", "start") |> render_click()
  end

  test "click stop", %{view: view} do
    send(view.pid, {:sim, started: true})
    html = render(view)
    assert html =~ "stop"
    assert view |> element("#start-button", "stop") |> render_click()
  end
end
