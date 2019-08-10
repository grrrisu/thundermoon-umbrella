defmodule ThundermoonWeb.ChatLive do
  use Phoenix.LiveView

  alias Thundermoon.Repo
  alias Thundermoon.Accounts.User

  def mount(session, socket) do
    user = Repo.get!(User, session[:current_user_id])
    {:ok, assign(socket, %{current_user: user})}
  end

  def render(assigns) do
    ThundermoonWeb.ChatView.render("index.html", assigns)
  end
end
