defmodule ThundermoonWeb.AuthSupport do
  import Plug.Test

  alias Thundermoon.Factory
  alias Thundermoon.Accounts.User

  def login_as(conn, %User{} = user) do
    init_test_session(conn, current_user_id: user.id)
  end

  def login_as(conn, %{} = user_params) do
    current_user = Factory.create(:user, user_params)
    login_as(conn, current_user)
  end
end
