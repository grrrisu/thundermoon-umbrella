#!/bin/sh
set -e

mix do ecto.migrate, run ./apps/thundermoon/priv/repo/seeds.exs
mix phx.server
