defmodule ThundermoonWeb.LotkaVolterraLive.Chart do
  use ThundermoonWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> set_x_axis()
     |> push_data_to_client()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="chart-container" phx-update="ignore">
      <canvas id="chart" phx-hook="LotkaVolterraChart" width="400" height="200"></canvas>
    </div>
    """
  end

  defp set_x_axis(%{assigns: %{x_axis: x}} = socket), do: assign(socket, x_axis: x + 1)
  defp set_x_axis(socket), do: assign(socket, x_axis: 0)

  defp push_data_to_client(socket) do
    {vegetation, herbivore, predator} = socket.assigns.field

    socket
    |> push_event("update-chart", %{
      x_axis: socket.assigns.x_axis,
      vegetation: vegetation.size,
      herbivore: herbivore && herbivore.size,
      predator: predator && predator.size
    })
  end
end
