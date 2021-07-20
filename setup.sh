#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

red() { echo -e "$(tput setaf 1)$*$(tput setaf 9)"; }
green() { echo -e "$(tput setaf 2)$*$(tput setaf 9)"; }
yellow() { echo -e "$(tput setaf 3)$*$(tput setaf 9)"; }

if ! command -v systemctl >/dev/null 2>&1; then
    red "> Sorry but this scripts is only for Linux Dist with systemd, eg: Ubuntu 16.04+/Centos 7+ ..."
    exit 1
fi

MTGBIN=/usr/local/bin/mtg
OSARCH=$(uname -m)
case $OSARCH in 
    x86_64)
        BINTAG=linux-amd64
        ;;
    i*86)
        BINTAG=linux-386
        ;;
    arm64)
        BINTAG=linux-arm64
        ;;
    arm*)
        BINTAG=linux-arm
        ;;
    *)
        red "unsupported OSARCH: $OSARCH"
        exit 1
        ;;
esac

DEFINPUT () {
    local DEFAULT=$1
    local INPUT
    read INPUT
    if [[ -z $INPUT ]]; then
        echo "$DEFAULT"
    else
        echo "$INPUT"
    fi
}

DLMTG() {
    if [[ -x $MTGBIN ]]; then
        yellow "> Old mtg found. Removing..."
        systemctl stop mtg
        rm -f $MTGBIN
    fi

    green "> Downloading mtg binary ..."
    DLTEMP=$(mktemp --suffix=.tar.gz)
    EXTMPDIR=$(mktemp -d)
    trap 'echo Signal caught, cleaning up >&2; cd /; /bin/rm -rf "$DLTEMP" "EXTMPDIR"; exit 15' 1 2 3 15

    wget -qO- https://api.github.com/repos/9seconds/mtg/releases/latest \
    | grep browser_download_url | grep "$BINTAG" | cut -d '"' -f 4 \
    | wget --no-verbose -i- -O $DLTEMP

    if [[ ! -f $DLTEMP ]]; then
        red ">Failed to download ..."
        exit 1
    fi

    yellow "> Now extracting ..."
    tar xvf $DLTEMP --strip-components=1 -C $EXTMPDIR

    yellow "> Install mtg binary ..."
    install -v -m755 $EXTMPDIR/mtg $MTGBIN

    yellow "> Install mtg done... version: `$MTGBIN --version`"
    rm -rf $DLTEMP $EXTMPDIR
}

LOCALMTG() {
    local mtgtar=$1
    if [[ ! -f $mtgtar ]]; then
        red ">Failed find $mtgtar..."
        exit 1
    fi
    if [[ -x $MTGBIN ]]; then
        yellow "> Old mtg found. Removing..."
        systemctl stop mtg
        rm -f $MTGBIN
    fi
    EXTMPDIR=$(mktemp -d)
    trap 'echo Signal caught, cleaning up >&2; cd /; /bin/rm -rf "EXTMPDIR"; exit 15' 1 2 3 15

    yellow "> Now extracting ..."
    tar xvf $mtgtar --strip-components=1 -C $EXTMPDIR

    yellow "> Install mtg binary ..."
    install -v -m755 $EXTMPDIR/mtg $MTGBIN

    yellow "> Install mtg done... version: `$MTGBIN --version`"
    rm -rf $EXTMPDIR
}

arg1="${1:-}"
if [[ ! -z $arg1 ]]; then
    if [[ ! -f $arg1 ]]; then
        arg1=$USER_PWD/$arg1
    fi
    if [[ ! -f $arg1 ]]; then
        red "> arg $arg1 does not exists"
        exit 1
    fi
    yellow "> Local tar found, using offline install mode"
fi

if [[ -f /etc/mtg.toml ]]; then
    yellow "> Previos config (/etc/mtg.toml) exists, only upgrade the mtg binary."
    if [[ -f $arg1 ]]; then LOCALMTG $arg1; else DLMTG; fi
    systemctl restart mtg
    yellow "> Upgrade succeffully. Here shows the recent logs"
    journalctl -u mtg --since '1 min ago' | tee
    green "> Setup mtproxy in telegram with following URL: "
    mtg access /etc/mtg.toml|grep tme_url
    green "> Bye."
    exit 0
fi


PORT=$(shuf -i 2000-65000 -n1)
FAKEDOMAIN=hostupdate.vmware.com
green "=================================================="
yellow ">Random port generated, input another if wish to change, press Enter to continue"
PORT=$(DEFINPUT $PORT)
yellow "Input a domain for FakeTLS mode, \"$FAKEDOMAIN\" will be used if left empty"
FAKEDOMAIN=$(DEFINPUT $FAKEDOMAIN)
green "=================================================="
yellow "> Using: PORT: ${PORT}, FakeTLS DOMAIN : ${FAKEDOMAIN}"
green "=================================================="

if [[ -f $arg1 ]]; then LOCALMTG $arg1; else DLMTG; fi
yellow "==================================================\n\n\n"
SECRET=$($MTGBIN generate-secret "$FAKEDOMAIN")

sed -i "s/#PORT#/$PORT/;s/#SECRET#/$SECRET/" $__dir/conf/mtg.toml
install -v -m644 $__dir/conf/mtg.service /etc/systemd/system/
install -v -m644 $__dir/conf/mtg.toml    /etc/

systemctl daemon-reload
systemctl enable --now mtg

yellow "==================================================\n\n\n"
green "> Installation Done. Waiting for service to load ..."
yellow "> Generated Secret: ${SECRET}"
yellow "> Listening Port: ${PORT}"
green ">  ..."
sleep 2
journalctl -u mtg --since today | tee
yellow "> Setup mtproxy in telegram with following URL: "
mtg access /etc/mtg.toml|grep tme_url
yellow "> To checkout all available urls, run\`mtg access /etc/mtg.toml'"
green "> Bye."
