defmodule ThundermoonWeb.GameOfLifeLive.Index do
  use ThundermoonWeb, :live_view

  import Canada.Can
  alias Phoenix.PubSub

  alias Thundermoon.Accounts

  alias ThundermoonWeb.GameOfLifeLive.{FormComponent, GridComponent, ActionButtonsComponent}

  def mount(_params, session, socket) do
    if connected?(socket), do: PubSub.subscribe(ThundermoonWeb.PubSub, "GameOfLife")

    {:ok,
     socket
     |> assign(current_user: get_current_user(session), grid: get_grid())}
  end

  def render(%{grid: nil} = assigns) do
    ~L"""
    <h1>Game of Life</h1>
    <%= if can?(@current_user, :create, GameOfLife) do %>
      <%= live_component @socket, FormComponent, id: "form" %>
    <% else %>
      <p>There's currently no simulation available.</p>
    <% end %>
    """
  end

  def render(%{grid: grid} = assigns) when not is_nil(grid) do
    ~L"""
    <h1>Game of Life</h1>
    <%= live_component @socket, GridComponent,
      id: "grid-#{@current_user.id}", grid: @grid %>
    <%= live_component @socket, ActionButtonsComponent,
      id: "action-buttons-#{@current_user.id}", current_user: @current_user %>
    """
  end

  @impl true
  def handle_info({:form_submitted, size}, socket) do
    GameOfLife.create(size)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, data: grid}, socket) do
    {:noreply, assign(socket, grid: grid)}
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
