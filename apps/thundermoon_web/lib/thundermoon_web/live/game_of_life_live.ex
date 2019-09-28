defmodule ThundermoonWeb.GameOfLifeLive do
  use Phoenix.LiveView

  import Canada.Can

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User
  alias Thundermoon.GameOfLife

  alias ThundermoonWeb.GameOfLifeView
  alias ThundermoonWeb.Endpoint
  alias ThundermoonWeb.Router.Helpers, as: Routes

  def mount(session, socket) do
    current_user = Repo.get!(User, session[:current_user_id])
    if connected?(socket), do: Endpoint.subscribe("Thundermoon.GameOfLife")
    grid = GameOfLife.get_grid()
    socket = set_label_sim_start(socket, GameOfLife.started?())
    {:ok, assign(socket, current_user: current_user, grid: grid)}
  end

  def render(assigns) do
    GameOfLifeView.render("index.html", assigns)
  end

  # this is triggered by live_view events
  def handle_event("create", %{"grid" => %{"size" => size}}, socket) do
    can_execute!(socket, :create, GameOfLife, fn socket ->
      GameOfLife.create(String.to_integer(size))
      {:noreply, socket}
    end)
  end

  def handle_event("toggle-sim-start", %{"action" => "start"}, socket) do
    GameOfLife.start()
    {:noreply, socket}
  end

  def handle_event("toggle-sim-start", %{"action" => "stop"}, socket) do
    GameOfLife.stop()
    {:noreply, socket}
  end

  def handle_event("clear", _value, socket) do
    GameOfLife.clear()
    {:noreply, socket}
  end

  def handle_event("restart", _value, socket) do
    GameOfLife.restart()
    {:noreply, socket}
  end

  def handle_event("recreate", _value, socket) do
    can_execute!(socket, :create, GameOfLife, fn socket ->
      GameOfLife.recreate()
      socket = set_label_sim_start(socket, false)
      {:noreply, assign(socket, %{grid: nil})}
    end)
  end

  def handle_info(%{event: "sim", payload: %{started: started}}, socket) do
    {:noreply, set_label_sim_start(socket, started)}
  end

  # this is triggered by the pubsub broadcast event
  def handle_info(%{event: "update", payload: %{grid: grid}}, socket) do
    {:noreply, assign(socket, grid: grid)}
  end

  defp set_label_sim_start(socket, started) do
    label = if started, do: "stop", else: "start"
    assign(socket, label_sim_start: label)
  end

  def can_execute!(socket, action, subject, func) do
    cond do
      socket.assigns.current_user |> can?(action, subject) ->
        func.(socket)

      true ->
        {:stop, not_authorized(socket)}
    end
  end

  defp not_authorized(socket) do
    socket
    |> put_flash(:error, "You are not authorized for this action")
    |> redirect(to: Routes.page_path(Endpoint, :index))
  end
end
