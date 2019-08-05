defmodule ThundermoonWeb.UserAbilities do
  alias Thundermoon.Accounts.User
  
  defimpl Canada.Can, for: User do

    def can?(%User{}, action, User) 
      when action in [:index], do: true

    def can?(%User{role: "admin"}, action, %User{}) 
      when action in [:edit, :update], do: true

    def can?(%User{id: user}, action, %User{id: user}) 
      when action in [:edit, :update], do: true

    def can?(%User{id: admin, role: "admin"}, action, %User{id: user}) 
      when action in [:delete] do
        admin != user
    end

    def can?(%User{}, action, %User{})
      when action in [:edit, :update, :delete], do: false

  end
end
