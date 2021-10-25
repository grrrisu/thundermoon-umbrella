defmodule Thundermoon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Thundermoon.Repo,
      Thundermoon.Memo.Server,
      Thundermoon.ChatMessages,
      Thundermoon.CounterRealmSupervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Thundermoon.Supervisor)
  end
end
