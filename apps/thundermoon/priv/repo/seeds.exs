# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Thundermoon.Repo.insert!(%Thundermoon.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Thundermoon.Factory
alias Thundermoon.Accounts

unless Accounts.find_by_external_id(123) do
  Factory.create(:user, %{external_id: 123, username: "crumb"})
end

unless Accounts.find_by_external_id(456) do
  Factory.create(:user, external_id: 456, username: "gilbert_shelton", role: "admin")
end
