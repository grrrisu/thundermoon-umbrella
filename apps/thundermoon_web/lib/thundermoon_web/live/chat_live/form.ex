defmodule ThundermoonWeb.ChatLive.Form do
  use ThundermoonWeb, :live_component

  alias Phoenix.PubSub
  alias Thundermoon.ChatMessages

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form let={f} for={:message} phx-target={@myself} phx-submit={:send} class="flex">
        <%= text_input f, :text, class: "input text-input", "data-version": @version, value: "", placeholder: "write a message" %>
        <%= submit "Send", class: "btn btn-primary ml-3 px-4 py-2" %>
      </.form>
    </div>
    """
  end

  # this is triggered by the live_view event phx-submit
  @impl true
  def handle_event("send", %{"message" => %{"text" => text}}, socket) do
    user = socket.assigns.current_user
    message = %{user: user.username, text: text, user_id: user.id}
    ChatMessages.add(message)
    PubSub.broadcast(ThundermoonWeb.PubSub, "chat", {:send, message})
    {:noreply, assign(socket, %{version: System.unique_integer()})}
  end
end
