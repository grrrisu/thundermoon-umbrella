defmodule ThundermoonWeb.AuthService do
  alias Ueberauth.Auth

  alias Thundermoon.Accounts

  def find_or_create(%Auth{} = auth) do
    user_params = basic_info(auth)
    Accounts.find_or_create(user_params)
  end

  defp basic_info(auth) do
    %{
      external_id: auth.uid,
      username: auth.info.nickname,
      name: name_from_auth(auth),
      avatar: avatar_from_auth(auth),
      email: auth.info.email
    }
  end

  # github response
  defp avatar_from_auth(%{info: %{urls: %{avatar_url: image}}}), do: image

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name =
        [auth.info.first_name, auth.info.last_name]
        |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end
end
