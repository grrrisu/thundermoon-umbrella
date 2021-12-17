# Changelog

## dev

- General:

  - update Elixir to 1.13.1

  - update Phoenix 1.6 and Phoenix Live View 0.17

  - various upgrades, Poison 5.0

  - update Chart.js to 3.6.0

  - replace Parcel with esbuild

  - update tailwindcss to 3.0

  - refactor Dockerfiles and reorganize CI/CD pipeline

## 0.7.0

- Chat:

  - extract message and chat to their own component

- Game Of Life:

  - push only changes to game of life live_view for faster rendering

  - adapt dimensions of grid to viewport

- Lotka Voltera

  - edit vegetation, herbivores or predators on the chart page

- Sim

  - update object within in vitro

- General:

  - implement the PETAL Stack

  - css: replaced milligram with tailwindcss

  - css: revamped the design with a new dark theme

  - included line-awesome as npm package

  - javascript: include Alpine 101

  - validate greater also validates smaller at same time

  - EctoType for simulated integers (are floats behind the scenes)

  - preview images on landing page

  - various upgrades

    - credo 1.5.5

    - parcel to 2.0.0-beta.3.1 (to make alpine work with parcel)

## 0.6.0

- Sim:

  - Introducing event sourcing

  - Replace the global lock CommandGuard with CommandBus

  - CommandBus and Domain Services executing commands in groups

  - EventBus handling events

  - Extract broadcasting as its own event reducer

- various upgrades

  - Elixir 1.11.2

  - Phoenix Live View 0.15

  - Phoenix Live Dashboard 0.4

## 0.5.0

- Components for counter (digit, action buttons)

- Components for game of life (form, grid, action buttons)

- shared components:

  - entity form

- Sim:

  - introduce command handlers

  - command guard to control concurrent workers on the data

  - SimulationLoop holds state of running flag

- Game of Life using commands

- Lotka Volterra

  - predators

- various upgrades

  - credo

## 0.4.0

- Lotka Volterra simulation

  - Vegetation with limited capacity

  - Herbivores eating vegetation

- Sim Laboratory:

  - InVitro are session like simulation containers that can be used per live_view

  - Registry will remove expired sim containers after a timeout

- started using shared components

  - Start button

- various upgrades

  - Phoenix Live View 0.14

  - sentry 8.0

## 0.3.2

- extract Game of Life as separate sub application, with its own supervision tree.

- refactor realm to a more robust architecture

  - Sim.Realm.Data: holds the data and broadcasts changes to PubSub. This part is the most robust one, the data will still be available even if the server and the simulation loop crash.

  - Sim.Realm.SimulationLoop: Has a recurring tick when the simulation is running. This will trigger the realm server to block all incoming request during simulation.

  - Sim.Realm.Server: All incoming request are going through this server. It also executes the sim funtions in a separate task.

  - There are two Supervisors, one to monitor the data and the simulation loop, the other monitors the server with its task supervisor.

- use macros to customize Sim.Realm context and server functions.

## 0.3.1

- various upgrades

  - Elixir 1.10.3

  - Phoenix 1.5.1

  - Phoenix Live View 0.13.3 (including new adaptions)

  - Phoenix PubSub 2.0

  - cypress 4.5.0

- include Phoenix Live Dashboard (dev only)

- improve pipeline by storing test containers for further steps

- split Dockerfile for pipline into test and release

- add credo to pipeline

- remove cypress from devDependencies

## 0.3.0

- new application `sim`

- Sim.Grid a 2 dimensional map

- Sim.Torus a grid with no borders

- abstraction of RealmSupervisor, Realm, SimulationLoop

- Game of Life live view

- Add Line-Awesome font

- extract common view logic to `view_helper.ex`

- Add Logger to context, simulation loop and realm

## 0.2.1

- Use Nginx as server service (not as docker container)
  with Letsencrypt (not as docker container)

- Counter example, with realm, root, context, simulation modules

- CSS variables to define colors

- Fix separate set current_user and check for member area

- Fix clear input field after sending chat message

- Update to Phoenix Live View 0.2.1

## 0.2.0

- Chat with Live View

- Store chat messages in GenServer

- integration tests with cypress.io

- new environment `integration` for CI

- new docker compose for integrtion on CI

- replace Bugsnag with Sentry

## 0.1.0

- Runs as Docker container

- Releases with Elixir 1.9

- CI/CD with Semaphore 2

- Assets via Parcel

- Bugsnag integration

- Authentication with Github account

- Authorization with Canada and Canary

- Phoenix Live View
