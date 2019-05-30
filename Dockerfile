# docker build -t thundermoon:builder --target=builder .
FROM elixir:1.8.2-alpine as builder
RUN apk add --no-cache \
    gcc \
    git \
    make \
    musl-dev
RUN mix local.rebar --force && \
    mix local.hex --force

WORKDIR /app
ENV MIX_ENV=prod

COPY mix.* /app/
COPY apps/thundermoon/mix.exs /app/apps/thundermoon/mix.exs
COPY apps/thundermoon_web/mix.exs /app/apps/thundermoon_web/mix.exs
RUN mix do deps.get --only prod, deps.compile

########################################################
# docker build -t thundermoon:assets --target=assets .
FROM node:8.16.0-alpine as assets

WORKDIR /app

COPY apps/thundermoon_web/assets/package*.json /app/apps/thundermoon_web/assets/
COPY --from=builder /app/deps/phoenix/ /app/deps/phoenix
COPY --from=builder /app/deps/phoenix_html/ /app/deps/phoenix_html

WORKDIR apps/thundermoon_web/assets
RUN npm ci
COPY apps/thundermoon_web/assets /app/apps/thundermoon_web/assets
RUN npm run deploy

########################################################
# docker build -t thundermoon:runner --target=runner .
FROM builder as runner

COPY --from=assets /app/apps/thundermoon_web/priv/static/ /app/apps/thundermoon_web/priv/static/
WORKDIR /app/apps/thundermoon_web/
RUN mix phx.digest

WORKDIR /app
COPY config/ /app/config
COPY apps/ /app/apps

#ENV DATABASE_URL ecto://192.168.1.2./thundermoon_dev
#ENV SECRET_KEY_BASE 8ikvBxNcx6vG5HtGcopT4K2BlUnTDyTPz2ZK304UDCUxjMKFq2kNT2KydwqVSLq7

RUN mix compile
#RUN mix release --env=prod
CMD ["mix", "phx.server"]
