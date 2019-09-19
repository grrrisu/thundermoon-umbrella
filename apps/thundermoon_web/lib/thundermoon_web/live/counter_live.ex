defmodule ThundermoonWeb.CounterLive do
  use Phoenix.LiveView

  import Canada.Can

  alias Thundermoon.Counter
  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  alias ThundermoonWeb.CounterView
  alias ThundermoonWeb.Endpoint
  alias ThundermoonWeb.Router.Helpers, as: Routes

  def mount(session, socket) do
    user = Repo.get!(User, session[:current_user_id])
    if connected?(socket), do: Endpoint.subscribe("counter")
    {:ok, _} = Counter.create()
    digits = Counter.get_digits()

    socket = set_label_sim_start(socket, Counter.started?())
    {:ok, assign(socket, current_user: user, digits: digits)}
  end

  def render(assigns) do
    CounterView.render("index.html", assigns)
  end

  def handle_event("inc", %{"number" => number}, socket) when number in ["1", "10", "100"] do
    Counter.inc(number)
    {:noreply, socket}
  end

  def handle_event("dec", %{"number" => number}, socket) when number in ["1", "10", "100"] do
    Counter.dec(number)
    {:noreply, socket}
  end

  def handle_event("toggle-sim-start", %{"action" => "start"}, socket) do
    Counter.start()
    {:noreply, socket}
  end

  def handle_event("toggle-sim-start", %{"action" => "stop"}, socket) do
    Counter.stop()
    {:noreply, socket}
  end

  def handle_event("reset", _value, socket) do
    cond do
      socket.assigns.current_user |> can?(:reset, Counter) ->
        Counter.reset()
        {:noreply, socket}

      true ->
        {:stop, not_authorized(socket)}
    end
  end

  def handle_info(%{event: "update", topic: "counter", payload: new_digit}, socket) do
    new_digits = Map.merge(socket.assigns.digits, new_digit)
    {:noreply, assign(socket, %{digits: new_digits})}
  end

  def handle_info(%{event: "sim", topic: "counter", payload: %{started: started}}, socket) do
    {:noreply, set_label_sim_start(socket, started)}
  end

  defp set_label_sim_start(socket, started) do
    label = if started, do: "stop", else: "start"
    assign(socket, label_sim_start: label)
  end

  defp not_authorized(socket) do
    socket
    |> put_flash(:error, "You are not authorized for this action")
    |> redirect(to: Routes.page_path(Endpoint, :index))
  end
end
