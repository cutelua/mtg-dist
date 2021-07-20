# mtg-dist
Binary dist script for mtg ( https://github.com/9seconds/mtg ).

## Note

Update: mtg 2.0+ supports FakeTLS mode only.
Re-run this script to upgrade.

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

# Customize

The configure file is at `/etc/mtg.toml`, refer to the offcial document for whatever you want to custom.

- https://github.com/9seconds/mtg 
- https://github.com/9seconds/mtg/blob/master/example.config.toml

After edited just restart the mtg service:

```
systemctl restart mtg 
```

# Compile
This project uses `makeself` to generate a `.bin` file.

Simple run `./makebin.sh`.
