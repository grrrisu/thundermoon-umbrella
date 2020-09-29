defmodule ThundermoonWeb.GameOfLifeLive.ActionButtonsComponent do
  use ThundermoonWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(started: GameOfLife.started?())}
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
