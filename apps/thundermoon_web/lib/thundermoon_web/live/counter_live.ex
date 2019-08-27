defmodule ThundermoonWeb.CounterLive do
  use Phoenix.LiveView

  import Canada.Can

  alias ThundermoonWeb.CounterView

  def mount(session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    CounterView.render("index.html", assigns)
  end

  def handle_event("inc", value, socket) do
    IO.puts("inc")
    {:noreply, socket}
  end

  def handle_event("dec", value, socket) do
    IO.puts("dec")
    {:noreply, socket}
  end
end
