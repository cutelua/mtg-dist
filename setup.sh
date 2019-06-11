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

PORT=$(shuf -i 2000-65000 -n1)
SECRET=$(head -c 512 /dev/urandom | md5sum | cut -f 1 -d ' ')

sed -i "s/#PORT#/$PORT/" $__dir/conf/mtg.conf
sed -i "s/#SECRET#/$SECRET/" $__dir/conf/mtg.service

install -v -m755 $__dir/bin/mtg          /usr/local/bin
install -v -m644 $__dir/conf/mtg.service /lib/systemd/system/
install -v -m644 $__dir/conf/mtg.conf    /etc/

systemctl daemon-reload
systemctl enable  mtg
systemctl restart mtg

sleep 3
wget -q -O - http://127.0.0.1:3129 | grep -E 'tme_url|tg_url'
