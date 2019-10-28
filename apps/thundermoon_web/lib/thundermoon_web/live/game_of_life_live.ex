defmodule ThundermoonWeb.GameOfLifeLive do
  use ThundermoonWeb, :live_view

  import Canada.Can

  alias Ecto.Changeset

  alias Phoenix.PubSub

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User
  alias GameOfLife.FormData

  alias ThundermoonWeb.GameOfLifeView
  alias ThundermoonWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    if connected?(socket), do: PubSub.subscribe(ThundermoonWeb.PubSub, "GameOfLife")
    grid = GameOfLife.get_root()

    socket =
      socket
      |> set_current_user(session)
      |> set_label_sim_start(GameOfLife.started?())
      |> set_empty_changeset()

    {:ok, assign(socket, grid: grid)}
  end

  def render(assigns) do
    GameOfLifeView.render("index.html", assigns)
  end

  # this is triggered by live_view events
  def handle_event("create", %{"form_data" => params}, socket) do
    can_execute!(socket, :create, GameOfLife, fn socket ->
      new_changeset = FormData.changeset(%FormData{}, params)

      socket =
        case Changeset.apply_action(new_changeset, :insert) do
          {:ok, data} ->
            GameOfLife.create(data.size)
            socket

          {:error, changeset} ->
            assign(socket, changeset: changeset)
        end

      {:noreply, socket}
    end)
  end

  def handle_event("toggle-sim-start", %{"action" => "start"}, socket) do
    GameOfLife.start_sim()
    {:noreply, socket}
  end

  def handle_event("toggle-sim-start", %{"action" => "stop"}, socket) do
    GameOfLife.stop_sim()
    {:noreply, socket}
  end

  def handle_event("toggle-cell", %{"x" => x, "y" => y}, socket) do
    GameOfLife.toggle(String.to_integer(x), String.to_integer(y))
    {:noreply, socket}
  end

  def handle_event("clear", _value, socket) do
    GameOfLife.clear()
    {:noreply, socket}
  end

  def handle_event("recreate", _value, socket) do
    GameOfLife.recreate()
    {:noreply, socket}
  end

  def handle_event("restart", _value, socket) do
    can_execute!(socket, :create, GameOfLife, fn socket ->
      GameOfLife.restart()

      socket =
        socket
        |> set_label_sim_start(false)
        |> set_empty_changeset()

      {:noreply, assign(socket, %{grid: nil})}
    end)
  end

  def handle_info({:sim, started: started}, socket) do
    {:noreply, set_label_sim_start(socket, started)}
  end

  # this is triggered by the pubsub broadcast event
  def handle_info({:update, data: grid}, socket) do
    {:noreply, assign(socket, grid: grid)}
  end

  defp set_label_sim_start(socket, started) do
    label = if started, do: "stop", else: "start"
    assign(socket, label_sim_start: label)
  end

  defp can_execute!(socket, action, subject, func) do
    cond do
      socket.assigns.current_user |> can?(action, subject) ->
        func.(socket)

      true ->
        {:noreply, not_authorized(socket)}
    end
  end

  defp set_current_user(socket, session) do
    current_user = Repo.get!(User, session["current_user_id"])
    assign(socket, %{current_user: current_user})
  end

  defp set_empty_changeset(socket) do
    changeset = FormData.changeset(%FormData{})
    assign(socket, %{changeset: changeset})
  end

  defp not_authorized(socket) do
    socket
    |> put_flash(:error, "You are not authorized for this action")
    |> redirect(to: Routes.page_path(socket, :index))
  end
end
