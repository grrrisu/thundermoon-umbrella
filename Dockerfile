# docker build -t thundermoon:builder --target=builder .
FROM elixir:1.9.4-alpine as builder
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
COPY --from=builder /app/deps/phoenix/ /app/deps/phoenix
COPY --from=builder /app/deps/phoenix_html/ /app/deps/phoenix_html
COPY --from=builder /app/deps/phoenix_live_view/ /app/deps/phoenix_live_view

WORKDIR /app/apps/thundermoon_web/assets
RUN npm ci
COPY apps/thundermoon_web/assets /app/apps/thundermoon_web/assets
RUN npm run deploy

########################################################
# docker build -t thundermoon:test --target=test .
FROM builder as test

COPY --from=assets /app/apps/thundermoon_web/priv/static/ /app/apps/thundermoon_web/priv/static/
#WORKDIR /app/apps/thundermoon_web/
#RUN mix phx.digest

WORKDIR /app
COPY config/ /app/config
COPY apps/ /app/apps
COPY .formatter.exs /app/
COPY mix.* /app/


ENV MIX_ENV=test
RUN mix do deps.get deps.compile compile

########################################################
# docker build -t thundermoon:integration --target=integration .
FROM builder as integration

COPY --from=assets /app/apps/thundermoon_web/priv/static/ /app/apps/thundermoon_web/priv/static/
WORKDIR /app/apps/thundermoon_web/
RUN mix phx.digest

WORKDIR /app
COPY config/ /app/config
COPY apps/ /app/apps

ENV SECRET_KEY_BASE set_later
ENV MIX_ENV=integration

RUN mix compile
COPY *.sh /app/
CMD ["/app/run_integration.sh"]

#########################################################
# docker build -t thundermoon:releaser --target=releaser .
FROM builder as releaser

COPY --from=assets /app/apps/thundermoon_web/priv/static/ /app/apps/thundermoon_web/priv/static/
WORKDIR /app/apps/thundermoon_web/
RUN mix phx.digest

WORKDIR /app
COPY config/ /app/config
COPY apps/ /app/apps

RUN mix compile
RUN mix release

#########################################################
# docker build -t thundermoon:app --target=app .
FROM alpine:3.10 as app

RUN apk add --update bash openssl

WORKDIR /app

COPY --from=releaser /app/_build/prod/rel/thundermoon_umbrella /app
COPY *.sh /app/

ENV HOME=/app

CMD ["/app/run.sh"]
