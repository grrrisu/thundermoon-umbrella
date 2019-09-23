defmodule ThundermoonWeb.GameOfLifeLive do
  use Phoenix.LiveView

  alias ThundermoonWeb.GameOfLifeView

  def mount(session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    GameOfLifeView.render("index.html", assigns)
  end
end
