# docker build -t thundermoon:dependencies --target=dependencies .
FROM elixir:1.9.4-alpine as dependencies
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
COPY apps/sim/mix.exs /app/apps/sim/mix.exs
COPY apps/thundermoon/mix.exs /app/apps/thundermoon/mix.exs
COPY apps/thundermoon_web/mix.exs /app/apps/thundermoon_web/mix.exs
RUN mix do deps.get --only prod, deps.compile

########################################################
# docker build -t thundermoon:assets --target=assets .
FROM node:8.16.2-alpine as assets

WORKDIR /app

COPY apps/thundermoon_web/assets/package*.json /app/apps/thundermoon_web/assets/
COPY --from=dependencies /app/deps/phoenix/ /app/deps/phoenix
COPY --from=dependencies /app/deps/phoenix_html/ /app/deps/phoenix_html
COPY --from=dependencies /app/deps/phoenix_live_view/ /app/deps/phoenix_live_view

WORKDIR /app/apps/thundermoon_web/assets
RUN npm ci
COPY apps/thundermoon_web/assets /app/apps/thundermoon_web/assets
RUN npm run deploy

########################################################
# docker build -t thundermoon:builder --target=builder .
FROM dependencies AS builder

WORKDIR /app
COPY --from=assets /app/apps/thundermoon_web/priv/static/ /app/apps/thundermoon_web/priv/static/
COPY apps/ /app/apps
COPY config/ /app/config

########################################################
# docker build -t thundermoon:test --target=test .
FROM builder as test

WORKDIR /app

COPY .formatter.exs /app/
COPY mix.* /app/


ENV MIX_ENV=test
RUN mix do deps.get deps.compile compile

########################################################
# docker build -t thundermoon:integration --target=integration .
FROM builder as integration

WORKDIR /app/apps/thundermoon_web/
RUN mix phx.digest

WORKDIR /app

ENV SECRET_KEY_BASE set_later
ENV MIX_ENV=integration

RUN mix compile
COPY *.sh /app/
CMD ["/app/run_integration.sh"]


