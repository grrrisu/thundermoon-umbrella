defmodule ThundermoonWeb.GameOfLifeLive.Index do
  use ThundermoonWeb, :live_view

  import Canada.Can
  alias Phoenix.PubSub

  require Logger

  alias Thundermoon.Accounts

  import ThundermoonWeb.GameOfLifeLive.{Grid, ActionButtons}
  alias ThundermoonWeb.GameOfLifeLive.FormComponent

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: PubSub.subscribe(ThundermoonWeb.PubSub, "GameOfLife")

    {:ok,
     socket
     |> assign(
       current_user: get_current_user(session),
       grid: get_grid(),
       started: GameOfLife.started?()
     )}
  end

  @impl true
  def render(%{grid: nil} = assigns) do
    ~H"""
    <h1>Game of Life</h1>
    <%= if can?(@current_user, :create, GameOfLife) do %>
      <.live_component module={FormComponent} id="form" />
    <% else %>
      <p>There's currently no simulation available.</p>
    <% end %>
    """
  end

  @impl true
  def render(%{grid: grid} = assigns) when not is_nil(grid) do
    ~H"""
    <h1>Game of Life</h1>
    <.matrix grid={@grid} />
    <.action_buttons current_user={@current_user} started={@started} />
    """
  end

  @impl true
  def handle_event("start", _, socket) do
    GameOfLife.start_sim()
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _, socket) do
    GameOfLife.stop_sim()
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _value, socket) do
    GameOfLife.clear()
    {:noreply, socket}
  end

  @impl true
  def handle_event("recreate", _value, socket) do
    GameOfLife.recreate()
    {:noreply, socket}
  end

  @impl true
  def handle_event("reset", _value, socket) do
    GameOfLife.reset()
    {:noreply, assign(socket, grid: nil)}
  end

  @impl true
  def handle_event("toggle-cell", %{"x" => x, "y" => y}, socket) do
    GameOfLife.toggle(String.to_integer(x), String.to_integer(y))
    {:noreply, socket}
  end

  @impl true
  def handle_info({:form_submitted, size}, socket) do
    GameOfLife.create(size)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, data: grid}, socket) do
    Logger.debug("set grid")
    {:noreply, assign(socket, grid: grid)}
  end

  @impl true
  def handle_info({:changed, changes: changes}, socket) do
    Logger.debug("change grid")
    changes = changes |> Enum.map(fn {{x, y}, cell} -> [x, y, cell] end)
    {:noreply, push_event(socket, "update-game-of-life", %{changes: changes})}
  end

  @impl true
  def handle_info({:error, message}, socket) do
    Logger.warn("error: #{message}")
    {:noreply, put_flash(socket, :error, "Error: #{message}")}
  end

  @impl true
  def handle_info({:sim, started: started}, socket) do
    {:noreply, assign(socket, started: started, grid: get_grid())}
  end

  defp get_current_user(session) do
    Accounts.get_user(session["current_user_id"])
  end

  defp get_grid() do
    GameOfLife.get_root()
  end
end
