#!/bin/sh
set -e

mix ecto.migrate
mix phx.server