defmodule ThundermoonWeb.UserAbilities do
  alias Thundermoon.Accounts.User
  alias Thundermoon.ChatMessages

  defimpl Canada.Can, for: User do
    # User
    def can?(%User{}, action, User)
        when action in [:index],
        do: true

    def can?(%User{role: "admin"}, action, %User{})
        when action in [:edit, :update],
        do: true

    def can?(%User{id: user}, action, %User{id: user})
        when action in [:edit, :update],
        do: true

    def can?(%User{id: admin, role: "admin"}, action, %User{id: user})
        when action in [:delete] do
      admin != user
    end

    def can?(%User{}, action, %User{})
        when action in [:edit, :update, :delete],
        do: false

    # ChatMessages
    def can?(%User{role: "admin"}, :delete, ChatMessages), do: true
    def can?(%User{}, _action, ChatMessages), do: false
  end
end
