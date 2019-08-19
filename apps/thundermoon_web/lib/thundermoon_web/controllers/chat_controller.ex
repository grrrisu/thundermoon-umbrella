defmodule ThundermoonWeb.ChatController do
  use ThundermoonWeb, :controller

  alias ThundermoonWeb.ChatMessages
  alias ThundermoonWeb.AuthorizationHelpers

  def delete(conn, _params) do
    cond do
      conn.assigns.current_user |> can?(:delete, ChatMessages) ->
        ChatMessages.clear()

        conn
        |> put_flash(:info, "All messages cleared")
        |> redirect(to: "/chat")

      true ->
        AuthorizationHelpers.handle_unauthorized(conn)
    end
  end
end
