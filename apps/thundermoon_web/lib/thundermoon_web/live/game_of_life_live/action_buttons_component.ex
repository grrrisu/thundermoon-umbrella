defmodule ThundermoonWeb.GameOfLifeLive.ActionButtonsComponent do
  use ThundermoonWeb, :live_component

  alias ThundermoonWeb.Component.ActionBox

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
  def handle_event("reset", _value, socket) do
    GameOfLife.reset()
    send(self(), {:update, data: nil})
    {:noreply, socket}
  end
end
