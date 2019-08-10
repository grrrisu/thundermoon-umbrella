defmodule ThundermoonWeb.ChatLive do
  use Phoenix.LiveView

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  def mount(session, socket) do
    user = Repo.get!(User, session[:current_user_id])
    messages = []
    {:ok, assign(socket, %{current_user: user, messages: messages})}
  end

  def render(assigns) do
    ThundermoonWeb.ChatView.render("index.html", assigns)
  end

  def handle_event("send", %{"message" => %{"text" => text}}, socket) do
    new_message = %{user: username(socket), text: text}
    messages = [new_message | socket.assigns.messages]
    {:noreply, assign(socket, %{messages: messages})}
  end

  defp username(socket) do
    socket.assigns.current_user.username
  end
end
