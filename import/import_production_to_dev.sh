#!/usr/bin/env bash
echo "importing..."
set -e

rsync -av --delete grrrisu@the_lab:/srv/backup/daily/thundermoon.zero-x.net/thundermoon_prod.dump ./import
rsync -av --delete grrrisu@the_lab:/srv/backup/daily/thundermoon.zero-x.net/thundermoon_prod.sql ./import
pg_restore --verbose --no-acl --no-owner --clean -d thundermoon_dev import/thundermoon_prod.dump

# rsync -av --delete grrrisu@xenon:/srv/sites/www.maredimaria.ch/images/ uploads/