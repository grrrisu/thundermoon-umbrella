defmodule ThundermoonWeb.CounterLive.Digit do
  use ThundermoonWeb, :live_component

  alias Thundermoon.Counter

  @impl true
  def handle_event("inc", _, socket) do
    Counter.inc(socket.assigns.digit)
    {:noreply, socket}
  end

  @impl true
  def handle_event("dec", _, socket) do
    Counter.dec(socket.assigns.digit)
    {:noreply, socket}
  end
end
