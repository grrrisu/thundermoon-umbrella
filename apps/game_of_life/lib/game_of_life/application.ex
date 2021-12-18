defmodule GameOfLife.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Sim.Realm.Supervisor,
       name: GameOfLife,
       domain_services: [
         user: GameOfLife.UserService,
         sim: GameOfLife.SimService
       ],
       reducers: [Thundermoon.PubSubReducer]}
    ]

    opts = [
      strategy: :one_for_one,
      name: GameOfLife
    ]

    Supervisor.start_link(children, opts)
  end
end
