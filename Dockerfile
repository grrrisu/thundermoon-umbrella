# docker build -t thundermoon:build .
FROM elixir:1.14.1-alpine

RUN apk add --no-cache build-base npm git python3 curl

WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

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
RUN npx tailwindcss --input=css/app.css --output=../priv/static/assets/app.css --postcss --minify
RUN npx cpx "./static/**/*" ../priv/static
RUN npx cpx "./node_modules/line-awesome/dist/line-awesome/fonts/*" ../priv/static/fonts

WORKDIR /app
RUN mix esbuild default --minify