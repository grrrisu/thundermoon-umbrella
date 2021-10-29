defmodule ThundermoonWeb.ChatLive.Index do
  use ThundermoonWeb, :live_view

  import Canada.Can

  alias Phoenix.PubSub

  alias Thundermoon.Accounts
  alias Thundermoon.ChatMessages

  alias ThundermoonWeb.Presence

  alias ThundermoonWeb.ChatLive.{Message, Form}

  def mount(_params, session, socket) do
    user = Accounts.get_user(session["current_user_id"])
    if connected?(socket), do: subscribe(user)
    messages = ChatMessages.list()
    users = get_users(Presence.list("chat"))
    {:ok, assign(socket, current_user: user, version: 0, messages: messages, users: users)}
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
