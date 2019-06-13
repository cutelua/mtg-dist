# mtg-dist
Binary dist script for mtg ( https://github.com/9seconds/mtg ).

# Install
```
bash <(wget -qO- https://git.io/mtg.sh)
```

# Uninstall
```
systemctl stop mtg && systemctl disable mtg 
rm -f /usr/local/bin/mtg /lib/systemd/system/mtg.service /etc/mtg.conf    
```

# Compile
The binary `bin/mtg` is directly compile from mtg repo. It's for `linux/amd64` only.

`./makebin.sh` builds self-extract script using `makeself`.
