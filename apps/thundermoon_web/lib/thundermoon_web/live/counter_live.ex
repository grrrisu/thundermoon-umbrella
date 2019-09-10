defmodule ThundermoonWeb.CounterLive do
  use Phoenix.LiveView

  import Canada.Can

  alias Thundermoon.CounterRealm

  alias ThundermoonWeb.CounterView
  alias ThundermoonWeb.Endpoint

  def mount(_session, socket) do
    Endpoint.subscribe("counter")
    {:ok, _} = CounterRealm.create()
    digits = CounterRealm.get_digits()
    {:ok, assign(socket, digits: digits)}
  end

  def render(assigns) do
    CounterView.render("index.html", assigns)
  end

  def handle_event("inc", value, socket) when value in ["1", "10", "100"] do
    CounterRealm.inc(value)
    {:noreply, socket}
  end

  def handle_event("dec", value, socket) when value in ["1", "10", "100"] do
    CounterRealm.dec(value)
    {:noreply, socket}
  end

  def handle_info(%{event: "update", topic: "counter", payload: new_digit}, socket) do
    new_digits = Map.merge(socket.assigns.digits, new_digit)
    {:noreply, assign(socket, %{digits: new_digits})}
  end

  def handle_info("update", socket) do
    digits = CounterRealm.get_digits()
    {:noreply, assign(socket, digits: digits)}
  end
end
