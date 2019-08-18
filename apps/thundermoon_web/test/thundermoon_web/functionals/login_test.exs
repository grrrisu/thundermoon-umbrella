defmodule ThundermoonWeb.LoginTest do
  use ThundermoonWeb.ConnCase
  use Hound.Helpers

  alias Thundermoon.Factory

  hound_session()

  test "vist root" do
    navigate_to("/")
    assert visible_text({:css, "h1"}) == "Welcome to Thundermoon!"
  end

  # test "dashboard" do
  #   current_user = Factory.create(:user, %{username: "crumb"})
  #   navigate_to("/dashboard?current_user_id=#{current_user.id}")
  #   assert visible_text({:css, "h1"}) == "Welcome crumb!"
  # end
end
