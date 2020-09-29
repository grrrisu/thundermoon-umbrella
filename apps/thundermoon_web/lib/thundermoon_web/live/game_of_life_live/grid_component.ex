defmodule ThundermoonWeb.GameOfLifeLive.GridComponent do
  use ThundermoonWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(width: Sim.Grid.width(assigns.grid), height: Sim.Grid.height(assigns.grid))}
  end

  @impl true
  def handle_event("toggle-cell", %{"x" => x, "y" => y}, socket) do
    GameOfLife.toggle(String.to_integer(x), String.to_integer(y))
    {:noreply, socket}
  end

  def cell_class(grid, x, y) do
    Sim.Grid.get(grid, x, y) |> alive_class()
  end

  defp alive_class(false), do: ""
  defp alive_class(true), do: "alive"
end
