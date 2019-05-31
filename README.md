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