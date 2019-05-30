defmodule Thundermoon.Repo do
  use Ecto.Repo,
    otp_app: :thundermoon,
    adapter: Ecto.Adapters.Postgres
end
