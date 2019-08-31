defmodule ThundermoonWeb.CounterLive do
  use Phoenix.LiveView

  import Canada.Can

  alias Thundermoon.Counter

  alias ThundermoonWeb.CounterView

  def mount(session, socket) do
    digits = Counter.get_digits()
    {:ok, assign(socket, digits: digits)}
  end

  def render(assigns) do
    CounterView.render("index.html", assigns)
  end

  def handle_event("inc", value, socket) do
    Counter.inc(value)
    send(self(), "update")
    {:noreply, socket}
  end

  def handle_event("dec", value, socket) do
    Counter.dec(value)
    send(self(), "update")
    {:noreply, socket}
  end

  def handle_info("update", socket) do
    digits = Counter.get_digits()
    {:noreply, assign(socket, digits: digits)}
  end
end
