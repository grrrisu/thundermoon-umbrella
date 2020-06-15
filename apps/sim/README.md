# Sim

![Sim.Realm Diagram](documentation/SimRealm.png)

* Sim.Realm.Data: holds the data and broadcasts changes to PubSub.
This part is the most robust one, the data will still be available even if the server and the simulation loop crash.

* Sim.Realm.SimulationLoop: Has a recurring tick when the simulation is running.
This will trigger the realm server to block all incoming request during simulation.

* Sim.Realm.Server: All incoming request are going through this server.
It also executes the sim funtions in a separate task.

* There are two Supervisors, one to monitor the data and the simulation loop, the other monitors the server with its task supervisor.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sim` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sim, "~> 0.3.2"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sim](https://hexdocs.pm/sim).
