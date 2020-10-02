defmodule ThundermoonWeb.CounterLive.ActionButtons do
  use ThundermoonWeb, :live_component

  import Canada.Can

  alias Thundermoon.Counter

  @impl true
  def handle_event("reset", _value, socket) do
    cond do
      can?(socket.assigns.current_user, :reset) ->
        Counter.reset()
        {:noreply, socket}

      true ->
        {:noreply, not_authorized(socket)}
    end
  end

  def can?(current_user, action) do
    can?(current_user, action, Thundermoon.Counter)
  end

  defp not_authorized(socket) do
    socket
    |> put_flash(:error, "You are not authorized for this action")
    |> redirect(to: Routes.page_path(socket, :index))
  end
end
