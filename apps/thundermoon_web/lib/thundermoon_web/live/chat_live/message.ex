defmodule ThundermoonWeb.ChatLive.Message do
  use ThundermoonWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_is_current_user
     |> assign_message_color}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex">
      <%= if @is_current_user do %>
        <div class="w-3/12"></div>
      <% end %>
      <div class={"#{@message_color} rounded-md px-4 py-2 mb-2 w-9/12"}>
        <div class="font-bold"><%= @message.user %></div>
        <div class="font-light"><%= @message.text %></div>
      </div>
      <%= unless @is_current_user do %>
        <div class="w-3/12"></div>
      <% end %>
    </div>
    """
  end

  defp assign_is_current_user(%{assigns: %{current_user: user, message: message}} = socket) do
    assign(socket, :is_current_user, user.id == message.user_id)
  end

  defp assign_message_color(socket) do
    color =
      case socket.assigns.is_current_user do
        true -> "bg-indigo-500"
        false -> "bg-gray-500"
      end

    assign(socket, :message_color, color)
  end
end
