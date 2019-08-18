#!/bin/sh
set -e

./bin/thundermoon_umbrella eval "Thundermoon.Release.migrate"
./bin/thundermoon_umbrella eval "Thundermoon.Release.seeds"
./bin/thundermoon_umbrella start > log/phoenix.log 2>&1
