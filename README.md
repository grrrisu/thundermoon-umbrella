[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2ab69a409d24453fa5431a92f7d9050e)](https://www.codacy.com/app/grrrisu/thundermoon-umbrella?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=grrrisu/thundermoon-umbrella&amp;utm_campaign=Badge_Grade)

# Thundermoon.Umbrella

[Changelog](./changelog.md)

Umbrella App for

* [Thundermoon](apps/thundermoon/README.md)

* [ThundermoonWeb](apps/thundermoon_web/README.md)

## Docker

to start the application in a docker container

first copy and rename the files in `.env` to `app` and `db`.

set the corresponding values in those files and then run:

```
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

* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.create`
* Install Node.js dependencies with `cd apps/thundermoon_apps/assets && npm install`
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Migration

to create a migration issue the command in `app/thundermoon` directory and specify the repo

`mix ecto.gen.migration create_user -r Thundermoon.Repo`

### Testing

#### Cypress

##### Install

```npm install cypress```

```
MIX_ENV=integration mix ecto.create
MIX_ENV=integration mix ecto.migrate
MIX_ENV=integration mix run apps/thundermoon/priv/repo/seeds.exs
```

##### Run

run the application

```MIX_ENV=integration mix phx.server```

start the cypress Test Runner

```npm run cypress```

start testing ....


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
  -e GITHUB_CLIENT_ID=<secret> \
  -e GITHUB_CLIENT_SECRET=<secret>
```

add `deploy-key` containing the private key to the secrets and add the pub key to the deploy server

```shell
sem create secret deploy-key -f ~/.ssh/id_rsa_semaphoreci:/home/semaphore/.keys/deploy-key
```
