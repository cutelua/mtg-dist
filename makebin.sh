#! /bin/sh
PKGNAME="mtg-dist"
BUILDTAG="${1:-src}"
PKGDESC="MTGDist [$BUILDTAG][build $(date '+%Y-%m-%d')]"
START="./setup.sh"
makeself --tar-extra "--exclude=.gitignore --exclude=.github --exclude=.git --exclude=README.md --exclude=makebin.sh --exclude=install.sh" . $PKGNAME.bin "$PKGDESC" $START
