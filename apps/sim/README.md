# Sim

![Sim.Realm Diagram](documentation/SimRealm.png)

* The **Custom.Realm** module acts as an entry point. It provides an API to convert incoming requests to commands. A command has the form of `{:context, :name, args}`. For example a function call `toggle(2, 3)` could be mapped to a command `{:user, :toggle, x: 2, y: 3}`

* **Sim.Realm.SimulationLoop**: Has a recurring tick when the simulation is running, that will trigger a *sim command*.

* The **Sim.Realm.CommandBus** receives all the commands and will group them according to the given context mapping into execution groups. Each group will execute only one command at once, all other commands for that group will be queued (fifo) until the task is free again. Groups should execute commands that don't interfere with each other. For example, one group can simulate the growth of the vegetation, while the other group executes user movements. These two calculations can be done in parallel as they change completely different data.
  The configuration maps the context coming from the command with a Domain Service, grouping them into the aforementioned execution groups. `[%{vegetation_sim: VegetationSimService, animal: AnimalService}, %{user: UserService}]`. Here vegetation and animal commands would be stimulated in sequence, while user input could be done in parallel.

* **Commands** are executed in **Domain Services**. They do the actual domain logic on the aggregate/data. In the end, they return an array of events, representing the made changes.
While the events are then used for side effects like changing the data in a database in the next steps, the changes done during calculation are applied to data in memory (**Sim.Data**) immediately. Like that the next execution of the same group will have the latest changes and will not for example simulate the same state twice or move to the same field twice, just because the data may not have been updated in time.

* The **EventBus** receives all *events* that happened in the services and calls all given reducers on each of them in parallel. The Reducers could include a **Broadcaster** sending the event back through a PubSub, storing it to Kafka, or building a persistent data representation in a database. 

* **Sim.Realm.Data**: holds the data. This part is the most robust one, the data will still be available even if the other parts like the command bus or the simulation loop would crash.