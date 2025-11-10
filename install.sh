
#!/usr/bin/env sh
PORT="${PORT:-4533}"
DYNV6_TOKEN="${DYNV6_TOKEN:-123}"
DYNV6_DNS="${DYNV6_DNS:-a.com}"
LOCAL_PATH="$PWD"



function  BASH()
{

curl -sSL -o package.json https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/package.json
curl -sSL -o index.js https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/index.js
sed -i "s|HOME|$LOCAL_PATH|g" index.js

mkdir -p "$LOCAL_PATH/file/music"
mkdir -p "$LOCAL_PATH/bin/navidrome"
cd  "$LOCAL_PATH/bin/navidrome"
curl -sSL -o navidrome.tar.gz  https://github.com/navidrome/navidrome/releases/download/v0.58.0/navidrome_0.58.0_linux_amd64.tar.gz
tar -zxvf navidrome.tar.gz
chmod +x navidrome
rm navidrome.tar.gz

curl -sSL -o navidrome.toml  https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/navidrome.toml
sed -i "s|HOME|$LOCAL_PATH|g" navidrome.toml
sed -i "s|4533|$PORT|g" navidrome.toml

echo "base is ok"

}


function  SSL()
{

curl -sSL -o package.json https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/package.json
curl -sSL -o index.js https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/index_ssl.js
sed -i "s|HOME|$LOCAL_PATH|g" index.js


# navidrome
mkdir -p "$LOCAL_PATH/file/music"
mkdir -p "$LOCAL_PATH/bin/navidrome"
cd  "$LOCAL_PATH/bin/navidrome"
if [ ! -f navidrome ];then
curl -sSL -o navidrome.tar.gz  https://github.com/navidrome/navidrome/releases/download/v0.58.0/navidrome_0.58.0_linux_amd64.tar.gz
tar -zxvf navidrome.tar.gz
chmod +x navidrome
rm navidrome.tar.gz
fi

curl -sSL -o navidrome.toml  https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/navidrome.toml
sed -i "s|HOME|$LOCAL_PATH|g" navidrome.toml
#sed -i "s|4533|$PORT|g" navidrome.toml





# acme.sh
mkdir -p "$LOCAL_PATH/bin/acme/ssl"
cd "$LOCAL_PATH/bin/acme"
if [ ! -f acme.sh ];then
curl -sSL -o  acme.tar.gz https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
tar zxvf acme.tar.gz
mv acme.sh-master/*  .
rm -rf  acme.sh-master
rm acme.tar.gz
fi

./acme.sh --set-default-ca --issue --server letsencrypt --home "./ssl" -d "$DYNV6_DNS" --dns dns_dynv6  --debug  --force

curl -sSL -o ssl.sh  https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/ssl.sh
sed -i "s|HOME|$LOCAL_PATH|g" ssl.sh
sed -i "s|TOKEN0|$DYNV6_TOKEN|g" ssl.sh
sed -i "s|DYNV6_DNS|$DYNV6_DNS|g" ssl.sh
chmod +x "./ssl.sh"



# nginx
cd "$LOCAL_PATH/bin"
if [ ! -d "nginx" ];then
curl -sSL -o  nginx.zip https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/nginx.zip
unzip  nginx.zip
rm nginx.zip
chmod +x "./nginx/sbin/nginx"

cd "$LOCAL_PATH/bin/nginx/conf"
mv nginx.conf nginx.conf.bak
curl -sSL -o nginx.conf  https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/nginx.conf
sed -i "s|HOME|$LOCAL_PATH|g" "nginx.conf"
sed -i "s|443|$PORT|g"        "nginx.conf"
sed -i "s|DYNV6_DNS|$DYNV6_DNS|g" "nginx.conf"

cd "$LOCAL_PATH/bin/nginx/sbin"
curl -sSL -o  nginx.sh https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/nginx.sh
sed -i "s|HOME|$LOCAL_PATH|g" "nginx.sh"
chmod +x "./nginx.sh"

fi


ECC="_ecc"
mkdir -p "$LOCAL_PATH/bin/nginx/conf/ssl"
cp -f "$LOCAL_PATH/bin/acme/ssl/$DYNV6_DNS$ECC/fullchain.cer" "$LOCAL_PATH/bin/nginx/conf/ssl/fullchain.cer"
cp -f "$LOCAL_PATH/bin/acme/ssl/$DYNV6_DNS$ECC/$DYNV6_DNS.key" "$LOCAL_PATH/bin/nginx/conf/ssl/$DYNV6_DNS.key"


echo "ssl is ok"

}



# change ip for DYNV6_DNS
PUBLIC_IP=$(curl --silent http://4.ipw.cn)
echo "PUBLIC_IP is : $PUBLIC_IP"
sleep 2
RESULT=$(curl --silent "https://ipv4.dynv6.com/api/update?zone=$DYNV6_DNS&ipv4=8.8.8.8&token=$DYNV6_TOKEN")
echo "$RESULT"
if [ "$RESULT" == "addresses updated" ];then

SSL
curl  "https://ipv4.dynv6.com/api/update?zone=$DYNV6_DNS&ipv4=$PUBLIC_IP&token=$DYNV6_TOKEN"

else

BASH

fi










