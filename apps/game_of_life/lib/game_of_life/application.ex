defmodule GameOfLife.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Sim.Realm.Supervisor,
       name: GameOfLife,
       domain_services: [
         {GameOfLife.UserService, partition: :user, max_demand: 5},
         {GameOfLife.SimService, partition: :sim, max_demand: 1}
       ],
       reducers: [GameOfLife.PubSubReducer]}
    ]

    opts = [
      strategy: :one_for_one,
      name: GameOfLife
    ]

    Supervisor.start_link(children, opts)
  end
end
