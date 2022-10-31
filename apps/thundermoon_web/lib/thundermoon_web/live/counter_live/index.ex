defmodule ThundermoonWeb.CounterLive.Index do
  use ThundermoonWeb, :live_view

  import Canada.Can

  alias Phoenix.PubSub

  import ThundermoonWeb.CounterLive.{Digit, ActionButtons}

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
  def handle_event("inc", %{"digit" => digit}, socket) do
    digit |> String.to_integer() |> Counter.inc()
    {:noreply, socket}
  end

  @impl true
  def handle_event("dec", %{"digit" => digit}, socket) do
    digit |> String.to_integer() |> Counter.dec()
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _value, socket) do
    cond do
      can?(socket.assigns.current_user, :reset, Thundermoon.Counter) ->
        Counter.reset()
        {:noreply, socket}

      true ->
        {:noreply, not_authorized(socket)}
    end
  end

  @impl true
  def handle_event("start", _, socket) do
    Counter.start()
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _, socket) do
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

  defp not_authorized(socket) do
    socket
    |> put_flash(:error, "You are not authorized for this action")
    |> redirect(to: Routes.page_path(socket, :index))
  end
end
