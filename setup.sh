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

if ! command -v systemctl >/dev/null 2>&1; then
    echo "> Sorry but this scripts is only for Linux Dist with systemd, eg: Ubuntu 16.04+/Centos 7+ ..."
    exit 1
fi

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
        echo "unsupported OSARCH: $OSARCH"
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

PORT=$(shuf -i 2000-65000 -n1)
FAKEDOMAIN=bing.com
echo "=================================================="
echo -e ">Random port generated, input another if wish to change, press Enter to continue"
PORT=$(DEFINPUT $PORT)
echo "Input a domain for FakeTLS mode, \"bing.com\" will be used if left empty"
FAKEDOMAIN=$(DEFINPUT $FAKEDOMAIN)
echo "=================================================="
echo -e "> Using: PORT: ${PORT}, FakeTLS DOMAIN : ${FAKEDOMAIN}"
echo "=================================================="

MTGBIN=/usr/local/bin/mtg
if [[ -x $MTGBIN ]]; then
    echo ">Old mtg found. Removing..."
    systemctl stop mtg
    rm -f $MTGBIN
fi

echo "> Downloading mtg binary ..."
wget -qO- https://api.github.com/repos/9seconds/mtg/releases/latest \
| grep browser_download_url | grep "$BINTAG" | cut -d '"' -f 4 \
| wget --no-verbose -i- -O $MTGBIN

if [[ ! -f $MTGBIN ]]; then
    echo ">Failed to download ..."
    exit 1
fi

echo -e "==================================================\n\n\n"
chmod 755 $MTGBIN
$MTGBIN --version
SECRET=$($MTGBIN generate-secret --hex "$FAKEDOMAIN")

sed -i "s/#PORT#/$PORT/" $__dir/conf/mtg.conf
sed -i "s/#SECRET#/$SECRET/" $__dir/conf/mtg.service
install -m644 $__dir/conf/mtg.service /lib/systemd/system/
install -m644 $__dir/conf/mtg.conf    /etc/

systemctl daemon-reload
systemctl enable  mtg
systemctl restart mtg

echo -e "==================================================\n\n\n"
echo ">Installation Done. Waiting for service to load ..."
sleep 2
echo "> Generated Secret: ${SECRET}"
echo "> Mtg listening at port: ${PORT}"
echo ">  ..."
#SADDR=$(wget -qO- -4 https://www.cloudflare.com/cdn-cgi/trace | grep 'ip=' | cut -d= -f2)
echo "> Setup mtproxy in telegram with following URL: "
journalctl -u mtg --since today | grep tme_url
echo ""
echo "> Bye."
