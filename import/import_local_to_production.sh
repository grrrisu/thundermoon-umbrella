#!/usr/bin/env bash
set -e

rsync -a --delete ./import/thundermoon_prod.* grrrisu@argon:/srv/backup/weekly/thundermoon.zero-x.net/
rsync -a --delete ./import/import.sh grrrisu@argon:/srv/backup/weekly/thundermoon.zero-x.net/import.sh

ssh -o StrictHostKeyChecking=no grrrisu@argon sh /srv/backup/weekly/thundermoon.zero-x.net/import.sh