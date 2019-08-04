defmodule ThundermoonWeb.AuthSupport do
  import Plug.Test

  def login_as(conn, user) do
    init_test_session(conn, current_user_id: user.id)
  end
end
