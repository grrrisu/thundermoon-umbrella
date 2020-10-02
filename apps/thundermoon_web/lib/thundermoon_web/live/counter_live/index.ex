defmodule ThundermoonWeb.CounterLive.Index do
  use ThundermoonWeb, :live_view

  import Canada.Can

  alias Phoenix.PubSub

  alias Thundermoon.Counter
  alias Thundermoon.Accounts

  alias ThundermoonWeb.CounterView
  alias ThundermoonWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    user = Accounts.get_user(session["current_user_id"])
    if connected?(socket), do: PubSub.subscribe(ThundermoonWeb.PubSub, "counter")
    {:ok, _} = Counter.create()
    digits = Counter.get_digits()

    {:ok, assign(socket, current_user: user, started: Counter.started?(), digits: digits)}
  end

  def handle_event("inc", %{"number" => number}, socket) when number in ["1", "10", "100"] do
    Counter.inc(number)
    {:noreply, socket}
  end

  def handle_event("dec", %{"number" => number}, socket) when number in ["1", "10", "100"] do
    Counter.dec(number)
    {:noreply, socket}
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

  def handle_event("reset", _value, socket) do
    cond do
      socket.assigns.current_user |> can?(:reset, Counter) ->
        Counter.reset()
        {:noreply, socket}

      true ->
        {:noreply, not_authorized(socket)}
    end
  end

  def handle_info({:update, new_digit}, socket) do
    new_digits = Map.merge(socket.assigns.digits, new_digit)
    {:noreply, assign(socket, %{digits: new_digits})}
  end

  def handle_info({:sim, started: started}, socket) do
    {:noreply, assign(socket, started: started)}
  end

  defp not_authorized(socket) do
    socket
    |> put_flash(:error, "You are not authorized for this action")
    |> redirect(to: Routes.page_path(socket, :index))
  end
end
