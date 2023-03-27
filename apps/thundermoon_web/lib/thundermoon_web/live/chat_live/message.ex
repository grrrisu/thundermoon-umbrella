defmodule ThundermoonWeb.ChatLive.Message do
  use ThundermoonWeb, :html
  use Phoenix.HTML

  def message(assigns) do
    assigns = assign(assigns, color: message_color(assigns), aligne: align_message(assigns))

    ~H"""
    <div class={"flex #{@aligne}"}>
      <div class={"#{@color} rounded-md px-4 py-2 mb-2 w-9/12"}>
        <div class="font-bold"><%= @message.user %></div>
        <div class="font-light"><%= @message.text %></div>
      </div>
    </div>
    """
  end

  def input_form(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={%{}} as={:message} phx-submit={:send} class="flex">
        <.text_input field={f[:text]} value="" placeholder="write a message" data-version={@version} />
        <%= submit("Send", class: "btn btn-primary ml-3 px-4 py-2") %>
      </.form>
    </div>
    """
  end

  defp align_message(assigns) do
    if is_current_user?(assigns), do: "justify-end", else: "justify-start"
  end

  defp message_color(assigns) do
    if is_current_user?(assigns), do: "bg-indigo-500", else: "bg-gray-500"
  end

  defp is_current_user?(%{current_user: current_user, message: message}) do
    current_user.id == message.user_id
  end
end
