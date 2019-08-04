defmodule ThundermoonWeb.AuthServiceTest do
  use ThundermoonWeb.ConnCase

  alias Thundermoon.Factory
  alias Thundermoon.Accounts.User

  alias ThundermoonWeb.AuthService

  def setup_user do
    Factory.create(:user, %{external_id: 123, username: "art_spiegelman"})
  end

  test "return authenticated user" do
    setup_user()

    auth = %Ueberauth.Auth{
      uid: 123,
      info: %Ueberauth.Auth.Info{
        nickname: "art_spiegelman",
        name: "Art Spiegelman",
        email: "art@spiegelman.com",
        urls: %{
          avatar_url: "http://example.com/art.png"
        }
      }
    }

    {:ok, user} = AuthService.find_or_create(auth)
    assert %User{external_id: 123, username: "art_spiegelman"} = user
  end

  test "create authenticated user" do
    auth = %Ueberauth.Auth{
      uid: 777,
      info: %Ueberauth.Auth.Info{
        nickname: "bill_griffith",
        name: "Bill Griffith",
        email: "bill@griffith.com",
        urls: %{
          avatar_url: "http://example.com/bill.png"
        }
      }
    }

    {:ok, user} = AuthService.find_or_create(auth)

    assert %User{
             external_id: 777,
             username: "bill_griffith",
             name: "Bill Griffith",
             email: "bill@griffith.com",
             avatar: "http://example.com/bill.png"
           } = user
  end
end
