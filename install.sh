#!/bin/sh
set -o errexit
set -o pipefail
set -o nounset

TMPDIR=$(mktemp -d)
trap 'echo Signal caught, cleaning up >&2; cd /; rm -rf "\$TMPDIR"; exit 15' 1 2 3 15

BIN=$TMPDIR/mtg.bin
wget -qO - https://api.github.com/repos/cutelua/mtg-dist/releases/latest \
| grep browser_download_url | cut -d '"' -f 4 | wget -q -i - -O $BIN
bash $BIN
rm -rf $TMPDIR