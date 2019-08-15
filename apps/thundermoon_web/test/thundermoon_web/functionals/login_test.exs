defmodule ThundermoonWeb.LoginTest do
  use ThundermoonWeb.ConnCase
  use Hound.Helpers

  hound_session()

  test "login" do
    navigate_to("/")
    assert visible_text({:css, "h1"}) == "Welcome to Thundermoon!"
  end
end
