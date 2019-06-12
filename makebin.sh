#! /bin/sh
PKGNAME="mtg-dist"
PKGDESC="Bullshit-free MTPROTO proxy Bin package [build $(date '+%Y-%m-%d')]"
START="./setup.sh"
BASEDIR="$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P )"

cd $BASEDIR
GITVER=$(git describe --tags || git rev-parse --short HEAD)
makeself --tar-extra "--exclude=.git --exclude=README.md --exclude=makebin.sh --exclude=install.sh" . ../$PKGNAME-$GITVER-$(date '+%Y%m%d-%H%M%S').bin "$PKGDESC" $START
