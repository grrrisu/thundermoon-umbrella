defmodule ThundermoonWeb.ChatLive.Message do
  use Phoenix.Component

  def row(assigns) do
    ~H"""
    <div class="flex">
      <.indent for_current_user={true} current_user={@current_user} message={@message} />
      <div class={"#{message_color(assigns)} rounded-md px-4 py-2 mb-2 w-9/12"}>
        <div class="font-bold"><%= @message.user %></div>
        <div class="font-light"><%= @message.text %></div>
      </div>
      <.indent for_current_user={false} current_user={@current_user} message={@message} />
    </div>
    """
  end

  defp indent(assigns) do
    ~H"""
      <div class={is_current_user?(assigns) == @for_current_user && "w-3/12"}></div>
    """
  end

  defp message_color(assigns) do
    if is_current_user?(assigns), do: "bg-indigo-500", else: "bg-gray-500"
  end

  defp is_current_user?(%{current_user: current_user, message: message}) do
    current_user.id == message.user_id
  end
end
