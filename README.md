# Thundermoon.Umbrella

## Docker

start application in a docker container

first copy and rename the files in `.env` to `app` and `db`.

set the corresponding values in those files and then run:

```
docker build -t thundermoon:runner --target=runner .
docker-compose up
```

stop application

```
docker-compose down
```

## Semaphore

set dockerhub credentials as semaphore secrets

```
sem create secret dockerhub-secrets \
  -e DOCKER_USERNAME=<your-dockerhub-username> \
  -e DOCKER_PASSWORD=<your-dockerhub-password>
```

set app specific credentials

````
sem create secret thundermoon-secrets -e DB_PASSWORD=<password> -e SECRET_KEY_BASE=<secret>
````

add `deploy-key` containing the private key to the secrets and add the pub key to the deploy server

````
sem create secret deploy-key -f ~/.ssh/id_rsa_semaphoreci:~/keys/deploy-key
```