[![Build Status](https://thundermoon.semaphoreci.com/badges/thundermoon-umbrella.svg?style=semaphore)](https://thundermoon.semaphoreci.com/badges/thundermoon-umbrella.svg?style=semaphore)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2ab69a409d24453fa5431a92f7d9050e)](https://www.codacy.com/app/grrrisu/thundermoon-umbrella?utm_source=github.com&utm_medium=referral&utm_content=grrrisu/thundermoon-umbrella&utm_campaign=Badge_Grade)

# Thundermoon.Umbrella

![Sim.Realm Diagram](thunderbirdmoon.png)

_image: Thunderbird Moon by Joe Wilson-Sxwaset_

This is a collection of examples using [phoenix live view](https://github.com/phoenixframework/phoenix_live_view).
The state is hold in memory and broadcasted to all clients.
The examples include a simple chat, a counter and [Conways Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

[Changelog](./changelog.md)

## Umbrella Apps

- [Thundermoon](apps/thundermoon/README.md)

- [ThundermoonWeb](apps/thundermoon_web/README.md)

- [Sim Library](apps/sim/README.md)

- [Game of Life](apps/game_of_life/README.md)

## Docker

to start the application in a docker container

first copy and rename the files in `.env` to `app` and `db`.

set the corresponding values in those files and then run:

```shell
docker build -t thundermoon:app --target=app .
IMAGE=thundermoon:app docker-compose up
```

stop application

```
docker-compose down
```

## Developement

### Setup

To start the application

- Copy `config/dev.secret.example.exs` to `config/dev.secret.exs` and replace ueberauth `client_id` and `client_secret` with your Github App credentials
- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix do ecto.create, ecto.migrate`
- Install Node.js dependencies with `cd apps/thundermoon_apps/assets && npm install`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Migration

to create a migration issue the command in `app/thundermoon` directory and specify the repo

`mix ecto.gen.migration create_user -r Thundermoon.Repo`

### New Sub Application

go to `./apps`and issue the mix new command like this:
 `mix new lotka_volterra --module LotkaVolterra --sup`

### Testing

#### Cypress

##### Install

`npm install -g cypress@4.5.0`

```shell
MIX_ENV=integration mix do ecto.create, ecto.migrate, run apps/thundermoon/priv/repo/seeds.exs
```

##### Run

run the application

`MIX_ENV=integration mix phx.server`

start the cypress Test Runner

`npm run cypress`

start testing ....

##### Docker

Run cypress with docker

`docker build -t thundermoon:integration --target=integration .`

`IMAGE="thundermoon:integration" docker-compose -f .semaphore/docker-compose.integration.yml up --abort-on-container-exit --exit-code-from browser`

### Release

manually test release can be built

```shell
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release

export SECRET_KEY_BASE=REALLY_LONG_SECRET
export DATABASE_URL=ecto://<user>:<password>@localhost/thundermoon_dev

_build/dev/rel/my_app/bin/my_app eval "Thundermoon.Release.migrate"
_build/prod/rel/thundermoon_umbrella/bin/thundermoon_umbrella start
```

## Production

stop docker stack

`docker stack rm thundermoon`

restart docker swarm

`TAG=<container_tag> deploy.sh`

### Debug

ssh into production server, then

```shell
docker ps
docker exec -it <container-id> sh
./bin/thundermoon_umbrella remote
```

```elixir
:observer_cli.start()
```

### Send Test Error

```shell
SENTRY_DSN=https://12345@sentry.io/123 MIX_ENV=prod mix sentry.send_test_event
```

## Semaphore

set dockerhub credentials as semaphore secrets

```shell
sem create secret dockerhub-secrets \
  -e DOCKER_USERNAME=<your-dockerhub-username> \
  -e DOCKER_PASSWORD=<your-dockerhub-password>
```

set app specific credentials

```shell
sem create secret thundermoon-secrets \
  -e DB_PASSWORD=<password> \
  -e SECRET_KEY_BASE=<secret> \
  -e SECRET_LIVE_VIEW_KEY=<secret> \
  -e SENTRY_DSN=<secret> \
  -e GITHUB_CLIENT_ID=<secret> \
  -e GITHUB_CLIENT_SECRET=<secret>
```

add `deploy-key` containing the private key to the secrets and add the pub key to the deploy server

```shell
sem create secret deploy-key -f ~/.ssh/id_rsa_semaphoreci:/home/semaphore/.keys/deploy-key
```
