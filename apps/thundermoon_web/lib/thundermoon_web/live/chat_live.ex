defmodule ThundermoonWeb.ChatLive do
  use Phoenix.LiveView

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  alias ThundermoonWeb.Endpoint
  alias ThundermoonWeb.ChatView

  def mount(session, socket) do
    user = Repo.get!(User, session[:current_user_id])
    Endpoint.subscribe("chat")
    messages = []
    {:ok, assign(socket, %{current_user: user, messages: messages})}
  end

  def render(assigns) do
    ChatView.render("index.html", assigns)
  end

  # this is triggered by the live_view event phx-submit
  def handle_event("send", %{"message" => %{"text" => text}}, socket) do
    username = socket.assigns.current_user.username
    message = %{user: username, text: text}
    Endpoint.broadcast("chat", "send", message)
    {:noreply, socket}
  end

  # this is triggered by the pubsub broadcast event
  def handle_info(%{event: "send", payload: message}, socket) do
    messages = [message | socket.assigns.messages]
    {:noreply, assign(socket, %{messages: messages})}
  end
end
