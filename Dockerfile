ARG MIX_ENV="prod"
ARG BUILD_IMAGE=build

# docker build -t thundermoon:build --target=build .
FROM elixir:1.12.3-alpine as build

RUN apk add --no-cache build-base npm git python3 curl

WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock ./
COPY apps/game_of_life/mix.exs ./apps/game_of_life/mix.exs
COPY apps/lotka_volterra/mix.exs ./apps/lotka_volterra/mix.exs
COPY apps/sim/mix.exs ./apps/sim/mix.exs
COPY apps/thundermoon/mix.exs ./apps/thundermoon/mix.exs
COPY apps/thundermoon_web/mix.exs ./apps/thundermoon_web/mix.exs

RUN mix deps.get

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
RUN mkdir -p config
COPY config/ ./config
RUN mix deps.compile

COPY apps/ ./apps

# note: if your project uses a tool like https://purgecss.com/,
# which customizes asset compilation based on what it finds in
# your Elixir templates, you will need to move the asset compilation
# step down so that `lib` is available.
WORKDIR /app/apps/thundermoon_web/assets

RUN npm ci
ENV NODE_ENV=production
RUN npx tailwindcss --input=css/app.css --output=../priv/static/assets/app.css --postcss
RUN npx cpx "./static/**/*" ../priv/static
RUN npx cpx "./node_modules/line-awesome/dist/line-awesome/fonts/*" ../priv/static/fonts

WORKDIR /app
RUN mix esbuild default --minify

########################################################
# docker build -t --target=test thundermoon:test .
FROM $BUILD_IMAGE AS test

WORKDIR /app

COPY .formatter.exs /app/

ENV MIX_ENV=test
RUN mix compile

########################################################
# docker build -t thundermoon:integration --target=integration .
FROM $BUILD_IMAGE as integration

WORKDIR /app

ENV SECRET_KEY_BASE set_later
ENV MIX_ENV=integration

COPY config/dev.secret.exs ./config/dev.secret.exs

RUN mix compile
COPY *.sh /app/
CMD ["/app/run_integration.sh"]

########################################################
# docker build -t thundermoon:releaser --target=releaser .
FROM $BUILD_IMAGE as releaser

WORKDIR /app
ENV MIX_ENV=prod

# compile and build the release
RUN mix compile
# changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix phx.digest
RUN mix release

########################################################
# docker build -t thundermoon:app --target=app .
FROM alpine:3.12.1 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ARG MIX_ENV
ENV USER="elixir"

WORKDIR "/home/${USER}/app"
# Creates an unprivileged user to be used exclusively to run the Phoenix app
RUN \
  addgroup \
   -g 1000 \
   -S "${USER}" \
  && adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "/home/${USER}" \
   -D "${USER}" \
  && su "${USER}"

# Everything from this line onwards will run in the context of the unprivileged user.
USER "${USER}"

COPY --from=releaser --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/thundermoon_umbrella ./
COPY --chown="${USER}":"${USER}" *.sh ./

CMD ["/app/run.sh"]