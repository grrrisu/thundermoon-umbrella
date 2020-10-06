defmodule ThundermoonWeb.CounterLive.Index do
  use ThundermoonWeb, :live_view

  alias Phoenix.PubSub

  alias Thundermoon.Counter
  alias Thundermoon.Accounts

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user(session["current_user_id"])
    if connected?(socket), do: PubSub.subscribe(ThundermoonWeb.PubSub, "counter")
    {:ok, _} = Counter.create()
    digits = Counter.get_digits()

    {:ok, assign(socket, current_user: user, started: Counter.started?(), digits: digits)}
  end

  @impl true
  def handle_info(:start, socket) do
    Counter.start()
    {:noreply, socket}
  end

  @impl true
  def handle_info(:stop, socket) do
    Counter.stop()
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, new_digit}, socket) do
    new_digits = Map.merge(socket.assigns.digits, new_digit)
    {:noreply, assign(socket, %{digits: new_digits})}
  end

  @impl true
  def handle_info({:sim, started: started}, socket) do
    {:noreply, assign(socket, started: started)}
  end
end
