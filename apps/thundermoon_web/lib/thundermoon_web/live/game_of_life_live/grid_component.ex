defmodule ThundermoonWeb.GameOfLifeLive.GridComponent do
  use ThundermoonWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(started: GameOfLife.started?())}
  end

  @impl true
  def handle_event("toggle-cell", %{"x" => x, "y" => y}, socket) do
    GameOfLife.toggle(String.to_integer(x), String.to_integer(y))
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
  def handle_event("restart", _value, socket) do
    GameOfLife.restart()
    send(self(), {:update, data: nil})
    {:noreply, socket}
  end
end
