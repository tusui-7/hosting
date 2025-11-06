#!/usr/bin/env sh

PORT="${PORT:-8000}"

curl -sSL -o index.js https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/index.js
curl -sSL -o package.json https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/package.json


mkdir -p /home/container/bin/navidrome
cd /home/container/bin/navidrome
curl -sSL -o navidrome.tar.gz  https://github.com/navidrome/navidrome/releases/download/v0.58.0/navidrome_0.58.0_linux_amd64.tar.gz
tar -zxvf navidrome.tar.gz
chmod +x navidrome
rm navidrome.tar.gz

curl -sSL -o navidrome.toml  https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/navidrome.toml
sed -i "s/8000/$PORT/g" navidrome.toml

echo "it is ok"

