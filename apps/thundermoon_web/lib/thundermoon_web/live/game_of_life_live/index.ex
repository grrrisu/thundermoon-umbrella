defmodule ThundermoonWeb.GameOfLifeLive.Index do
  use ThundermoonWeb, :live_view

  import Canada.Can
  alias Phoenix.PubSub

  require Logger

  alias Thundermoon.Accounts

  alias ThundermoonWeb.GameOfLifeLive.{FormComponent, GridComponent, ActionButtonsComponent}

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: PubSub.subscribe(ThundermoonWeb.PubSub, "GameOfLife")

    {:ok,
     socket
     |> assign(current_user: get_current_user(session), grid: get_grid())}
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
    <.live_component module={GridComponent} id={"grid-#{@current_user.id}"} grid={@grid} />
    <.live_component module={ActionButtonsComponent} id={"action-buttons-#{@current_user.id}"} current_user={@current_user} />
    """
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
  def handle_info({:command_failed, command: command, reason: _reason}, socket) do
    Logger.warn("command failed: #{inspect(command)}")
    {:noreply, put_flash(socket, :error, "command failed #{inspect(command)}")}
  end

  @impl true
  def handle_info(:start, socket) do
    GameOfLife.start_sim()
    {:noreply, socket}
  end

  @impl true
  def handle_info(:stop, socket) do
    GameOfLife.stop_sim()
    {:noreply, socket}
  end

  @impl true
  def handle_info({:sim, started: started}, socket) do
    send_update(ActionButtonsComponent,
      id: "action-buttons-#{socket.assigns.current_user.id}",
      started: started
    )

    {:noreply, socket}
  end

  defp get_current_user(session) do
    Accounts.get_user(session["current_user_id"])
  end

  defp get_grid() do
    GameOfLife.get_root()
  end
end
