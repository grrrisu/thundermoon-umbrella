# Sim

![Sim.Realm Diagram](documentation/SimRealm.png)

- The **Custom.Realm** module acts as an entry point. It provides an API to convert incoming requests to commands. A command has the form of `{:context, :name, args}`. For example a function call `toggle(2, 3)` could be mapped to a command `{:user, :toggle, x: 2, y: 3}`

- **Sim.Realm.SimulationLoop**: Has a recurring tick when the simulation is running, that will trigger a _sim command_.

- The **Sim.Realm.CommandBus** receives all the commands and will group them according to the given context mapping into execution groups. Each group will be forwarded their events defined in the **context** of the event. Each group will execute their events independent from the other ones. Groups should therfore execute commands that don't interfere with each other. For example, one group can simulate the growth of the vegetation, while the other group executes user movements. These two calculations can be done in parallel as they change completely different data.

- **Commands** are executed in **Domain Services**. They do the actual domain logic on the aggregate/data. In the end, they return an array of events, representing the made changes.
  While the events are then used for side effects like changing the data in a database in the next steps, the changes done during calculation are applied to data in memory (**Sim.Data**) immediately. Like that the next execution of the same group will have the latest changes and will not for example simulate the same state twice or move to the same field twice, just because the data may not have been updated in time.

- The **EventBus** receives a list of _events_ and/or _commands_ that happened in the services. It will send command to the _CommandBus_, while events will be broadcasted via each EventReducer.

- The **EventReducers** save the event to the database, a message broker or publish it via a PubSub component.

- **Sim.Realm.Data**: holds the data. This part is the most robust one, the data will still be available even if the other parts like the command bus or the simulation loop would crash.

## Application

example configuration:

```elixir
{Sim.Realm.Supervisor,
  name: MyApp,
  domain_services: [
    {MyService, partition: :my_service, max_demand: 5},
    {OtherService, partition: :other_service, max_demand: 1}
  ],
  reducers: [MyApp.PubSubReducer]
}
```

## Context

```elixir
defmodule MyApp do
  use Sim.Realm, app_module: __MODULE__

  def move(id, to: position) do
    send_command(:my_service, :move, id: id, to: position)
  end
end
```

## Domain Service

```elixir
defmodule MyService
  use Sim.Commands.DataHelpers, app_module: MyApp

  def execute(:move, id: id, to: {x, y}) do
    # executed by Data
    root = get_data()

    move_change(root, id, x, y)
    update_data(fn data, change -> update_map(data, change) end)
    [:moved, id: id, x: x, y: y]
  end

  # executed by MyService
  defp move_change(root, id, x, y)
    get_map(root) |> move(id, x, y)
  end

  # executed by Data
  defp update_map(root, change) do
    {:ok, apply_map_change(root, change)}
  end
```

or

```elixir
defmodule MyService
  use Sim.Commands.DataHelpers, app_module: MyApp
  @behaviour Sim.CommandHandler

  def execute(:move, id: id, to: {x, y}) do
    res = change_data(&move_change(&1, id, x, y), &update_map(&1, &2))
    case res do
      :ok -> [:moved, id: id, to: {x, y}]
      {:ok, events} -> events
      {:error, reason} -> [:move_failed, :id, id, reason: reason]
    end
  end
end
```

## EventReducer

```elixir
defmodule MyApp.PubSubReducer do
  def reduce(events) do
    Enum.map(events, fn event ->
      Phoenix.PubSub.broadcast(MyApp.PubSub, "MyApp", event)
    end)
  end
end
```
