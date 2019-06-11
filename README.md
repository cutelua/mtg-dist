# mtg-dist
Binary dist script for mtg.

# Install
```
wget -q -O - https://api.github.com/repos/cutelua/mtg-dist/releases/latest \
| grep browser_download_url \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -q -i - -O /tmp/mtg.bin && bash /tmp/mtg.bin && rm -f /tmp/mtg.bin 
```
