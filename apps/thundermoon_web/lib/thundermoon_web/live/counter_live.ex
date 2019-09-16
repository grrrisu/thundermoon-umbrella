defmodule ThundermoonWeb.CounterLive do
  use Phoenix.LiveView

  import Canada.Can

  alias Thundermoon.Counter
  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  alias ThundermoonWeb.CounterView
  alias ThundermoonWeb.Endpoint

  def mount(session, socket) do
    user = Repo.get!(User, session[:current_user_id])
    Endpoint.subscribe("counter")
    {:ok, _} = Counter.create()
    digits = Counter.get_digits()
    {:ok, assign(socket, current_user: user, digits: digits)}
  end

  def render(assigns) do
    CounterView.render("index.html", assigns)
  end

  def handle_event("inc", value, socket) when value in ["1", "10", "100"] do
    Counter.inc(value)
    {:noreply, socket}
  end

  def handle_event("dec", value, socket) when value in ["1", "10", "100"] do
    Counter.dec(value)
    {:noreply, socket}
  end

  def handle_event("reset", _value, socket) do
    if socket.assigns.current_user |> can?(:reset, Counter) do
      Counter.reset()
    end

    {:noreply, socket}
  end

  def handle_info(%{event: "update", topic: "counter", payload: new_digit}, socket) do
    new_digits = Map.merge(socket.assigns.digits, new_digit)
    {:noreply, assign(socket, %{digits: new_digits})}
  end
end