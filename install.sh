#!/bin/sh
set -o errexit
set -o pipefail
set -o nounset

TMPDIR=$(mktemp -d)
BIN=$TMPDIR/mtg.bin
wget -q -O - https://api.github.com/repos/cutelua/mtg-dist/releases/latest \
| grep browser_download_url | cut -d '"' -f 4 | wget -q -i - -O $BIN
bash $BIN
rm -f $TMPDIR