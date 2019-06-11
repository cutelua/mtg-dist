#! /bin/sh
PKGNAME="mtg-dist"
PKGDESC="Bullshit-free MTPROTO proxy Bin package [build $(date '+%Y-%m-%d')]"
START="./setup.sh"
BASEDIR="$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P )"
cd $BASEDIR
makeself . ../$PKGNAME-$(date '+%Y%m%d-%H%M%S').bin "$PKGDESC" $START
