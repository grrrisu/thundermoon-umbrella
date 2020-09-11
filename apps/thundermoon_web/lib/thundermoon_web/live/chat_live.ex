defmodule ThundermoonWeb.ChatLive do
  use ThundermoonWeb, :live_view

  import Canada.Can

  alias Phoenix.PubSub

  alias Thundermoon.Accounts
  alias Thundermoon.ChatMessages

  alias ThundermoonWeb.ChatView
  alias ThundermoonWeb.Presence

  def mount(_params, session, socket) do
    user = Accounts.get_user(session["current_user_id"])
    if connected?(socket), do: subscribe(user)
    messages = ChatMessages.list()
    users = get_users(Presence.list("chat"))
    {:ok, assign(socket, %{current_user: user, version: 0, messages: messages, users: users})}
  end

  def render(assigns) do
    ChatView.render("index.html", assigns)
  end

  # this is triggered by the live_view event phx-submit
  def handle_event("send", %{"message" => %{"text" => text}}, socket) do
    username = socket.assigns.current_user.username
    message = %{user: username, text: text}
    ChatMessages.add(message)
    PubSub.broadcast(ThundermoonWeb.PubSub, "chat", {:send, message})
    {:noreply, assign(socket, %{version: System.unique_integer()})}
  end

  def handle_event("clear", _value, socket) do
    if socket.assigns.current_user |> can?(:delete, ChatMessages) do
      ChatMessages.clear()
      PubSub.broadcast(ThundermoonWeb.PubSub, "chat", :clear)
    end

    {:noreply, socket}
  end

  # this is triggered by the pubsub broadcast event
  def handle_info({:send, message}, socket) do
    messages = [message | socket.assigns.messages]
    {:noreply, assign(socket, %{messages: messages})}
  end

  def handle_info(:clear, socket) do
    {:noreply, assign(socket, %{messages: []})}
  end

  # this is triggered if someone leaves or joins the chat
  def handle_info(
        %{
          event: "presence_diff",
          topic: "chat",
          payload: _payload
        },
        socket
      ) do
    users = get_users(Presence.list("chat"))

    {:noreply, assign(socket, %{users: users})}
  end

  defp subscribe(user) do
    PubSub.subscribe(ThundermoonWeb.PubSub, "chat")
    Presence.track(self(), "chat", user.id, %{user: user})
  end

  defp get_users(list) do
    list
    |> Map.values()
    |> Enum.map(&Map.get(&1, :metas))
    |> Enum.map(&List.first(&1))
    |> Enum.map(&Map.get(&1, :user))
  end
end
