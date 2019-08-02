# Thundermoon.Umbrella

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

### Migration

to create a migration issue the command in `app/thundermoon` directory and specify the repo

`mix ecto.gen.migration create_user -r Thundermoon.Repo`

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

```
sem create secret dockerhub-secrets \
  -e DOCKER_USERNAME=<your-dockerhub-username> \
  -e DOCKER_PASSWORD=<your-dockerhub-password>
```

set app specific credentials

```
sem create secret thundermoon-secrets \
  -e DB_PASSWORD=<password> \
  -e SECRET_KEY_BASE=<secret> \
  -e BUGSNAG_API_KEY=<secret>
```

add `deploy-key` containing the private key to the secrets and add the pub key to the deploy server

```
sem create secret deploy-key -f ~/.ssh/id_rsa_semaphoreci:/home/semaphore/.keys/deploy-key
```
