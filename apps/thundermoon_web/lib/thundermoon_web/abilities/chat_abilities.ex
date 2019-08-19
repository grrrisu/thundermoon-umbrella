defmodule ThundermoonWeb.ChatAbilities do
  alias Thundermoon.Accounts.User
  alias ThundermoonWeb.ChatMessages

  defimpl Canada.Can, for: User do
    def can?(%User{role: "admin"}, :delete, ChatMessages), do: true
    def can?(%User{}, _action, ChatMessages), do: false
  end
end
