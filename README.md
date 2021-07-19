# mtg-dist
Binary dist script for mtg ( https://github.com/9seconds/mtg ).

## Note

Update: mtg 2.0+ supports FakeTLS mode only.
Rerun this script to upgrade.

# Install
```
bash <(wget -qO- https://git.io/mtg.sh)
```

# Uninstall

```
systemctl disable --now mtg 
rm -f /usr/local/bin/mtg /etc/systemd/system/mtg.service /etc/mtg.toml   
```

## for version 0.0.6 and prior
```
systemctl disable --now mtg 
rm -f /usr/local/bin/mtg /lib/systemd/system/mtg.service /etc/mtg.conf    
```

# Compile
The binary `bin/mtg` is directly compile from mtg repo. It's for `linux/amd64` only.

`./makebin.sh` builds self-extract script using `makeself`.
