defmodule ThundermoonWeb.GameOfLifeLive.GridComponent do
  use ThundermoonWeb, :live_component

  alias Sim.Grid

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(width: Grid.width(assigns.grid), height: Grid.height(assigns.grid))
     |> assign_grid_css()}
  end

  @impl true
  def handle_event("toggle-cell", %{"x" => x, "y" => y}, socket) do
    GameOfLife.toggle(String.to_integer(x), String.to_integer(y))
    {:noreply, socket}
  end

  def cell_class(grid, x, y) do
    Grid.get(grid, x, y) |> alive_class()
  end

  defp alive_class(false), do: ""
  defp alive_class(true), do: "game-of-life-active"

  defp assign_grid_css(%{assigns: %{width: width, height: height}} = socket) do
    assign(
      socket,
      :grid_style,
      "grid-template-columns: repeat(#{width}, 1fr); grid-template-rows: repeat(#{height}, 1fr); width: 90vmin; height: 90vmin"
    )
  end
end
