defmodule ThundermoonWeb.GameOfLifeLive.Grid do
  use Phoenix.Component

  alias Sim.Grid

  def matrix(assigns) do
    assigns = matrix_assigns(assigns)

    ~H"""
    <div
      id="grid"
      class="grid auto-rows-fr mb-6 bg-gray-300 border-l border-b border-gray-900"
      style={"grid-template-columns: repeat(#{@width},1fr); grid-template-rows: repeat(#{@height},1fr); width: 85vmin; height: 85vmin"}
      phx-hook="GameOfLife">
      <%= for x <- 0..(@width - 1) do %>
        <%= for y <- 0..(@height - 1) do %>
          <.cell x={x} y={y} cell_class={cell_class(@grid, x, y)}/>
        <% end %>
      <% end %>
    </div>
    """
  end

  def cell(assigns) do
    ~H"""
    <div
      id={"cell_#{@x}_#{@y}"}
      class={"bg-gray-200 border-t border-r border-gray-900 cell #{@cell_class}"}
      phx-click="toggle-cell"
      phx-value-x={@x}
      phx-value-y={@y}>
    </div>
    """
  end

  def cell_class(grid, x, y) do
    Grid.get(grid, x, y) |> alive_class()
  end

  defp alive_class(false), do: ""
  defp alive_class(true), do: "game-of-life-active"

  defp matrix_assigns(assigns) do
    assigns
    |> assign_dimensions()
  end

  defp assign_dimensions(assigns) do
    assign(assigns, width: Grid.width(assigns.grid), height: Grid.height(assigns.grid))
  end
end
