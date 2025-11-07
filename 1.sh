
#!/usr/bin/env sh
PORT="${PORT:-5244}"
DYNV6_TOKEN="${DYNV6_TOKEN:-123}"
DYNV6_DNS="${DYNV6_DNS:-a.com}"
LOCAL_PATH="$PWD:-/home/container"



function  BASH()
{

curl -sSL -o package.json https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/package.json
cd "$LOCAL_PATH"
cat > "./index.js" <<EOF 

const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

// Binary and config definitions
const apps = [
  
  {
    name: "navidrome",
    binaryPath: "$LOCAL_PATH/bin/navidrome/navidrome",
    args: ["--configfile", "$LOCAL_PATH/bin/navidrome/navidrome.toml"],
    mode: "inherit"
  }
  
];


// Run binary with keep-alive
function runProcess(app) {
  const child = spawn(app.binaryPath, app.args, { stdio: "inherit" });

  child.on("exit", (code) => {
    console.log(`[EXIT] ${app.name} exited with code: ${code}`);
    console.log(`[RESTART] Restarting ${app.name}...`);
    setTimeout(() => runProcess(app), 10000); // restart after 3s
  });
}

// Main execution
function main() {
  try {
    for (const app of apps) {
      runProcess(app);
    }
  } catch (err) {
    console.error("[ERROR] Startup failed:", err);
    process.exit(1);
  }
}

main();


EOF
cat  "./index.js"


mkdir -p "$LOCAL_PATH/file/music"
mkdir -p "$LOCAL_PATH/bin/navidrome"
cd  "$LOCAL_PATH/bin/navidrome"
curl -sSL -o navidrome.tar.gz  https://github.com/navidrome/navidrome/releases/download/v0.58.0/navidrome_0.58.0_linux_amd64.tar.gz
tar -zxvf navidrome.tar.gz
chmod +x navidrome
rm navidrome.tar.gz

curl -sSL -o navidrome.toml  https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/navidrome.toml
sed -i "s|\/home|$LOCAL_PATH|g" navidrome.toml
sed -i "s/5244/$PORT/g" navidrome.toml

echo "base is ok"

}


function  SSL()
{

curl -sSL -o package.json https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/package.json
cd "$LOCAL_PATH"
cat > "./index.js" <<EOF 

const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

// Binary and co
const apps = [
  
  {
    name: "navidrome",
    binaryPath: "$LOCAL_PATH/bin/navidrome/navidrome",
    args: ["--configfile", "$LOCAL_PATH/bin/navidrome/navidrome.toml"],
    mode: "inherit"
  },
  
  {
    name: "acme",
    binaryPath: "bash",
    args: ["$LOCAL_PATH/bin/acme/cron.sh"],
    mode: "inherit"
  },
  
  {
    name: "nginx",
    binaryPath: "$LOCAL_PATH/bin/nginx/sbin/nginx",
    args: ["-c", "$LOCAL_PATH/bin/nginx/conf/nginx.conf"],
    mode: "inherit"
  }
  
];


// Run binary with keep-alive
function runProcess(app) {
  const child = spawn(app.binaryPath, app.args, { stdio: "inherit" });

  child.on("exit", (code) => {
    console.log(`[EXIT] ${app.name} exited with code: ${code}`);
    console.log(`[RESTART] Restarting ${app.name}...`);
    setTimeout(() => runProcess(app), 10000); // restart after 3s
  });
}

// Main execution
function main() {
  try {
    for (const app of apps) {
      runProcess(app);
    }
  } catch (err) {
    console.error("[ERROR] Startup failed:", err);
    process.exit(1);
  }
}

main();


EOF
cat  "./index.js"


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
sed -i "s|\/home|$LOCAL_PATH|g" navidrome.toml




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

ECC="_ecc"
cat > "./cron.sh" <<EOF 

for ((i=1; i<=750; i++))
do
sleep 3600
done

export DYNV6_TOKEN="$DYNV6_TOKEN"
"$LOCAL_PATH/bin/acme/acme.sh" --set-default-ca --issue --server letsencrypt --home "$LOCAL_PATH/bin/acme/ssl" -d "$DYNV6_DNS" --dns dns_dynv6  --debug  --force

sleep 60
mkdir -p "$LOCAL_PATH/bin/nginx/conf/ssl"
cp -f "$LOCAL_PATH/bin/acme/ssl/$DYNV6_DNS$ECC/fullchain.cer" "$LOCAL_PATH/bin/nginx/conf/ssl/fullchain.cer"
cp -f "$LOCAL_PATH/bin/acme/ssl/$DYNV6_DNS$ECC/$DYNV6_DNS.key" "$LOCAL_PATH/bin/nginx/conf/ssl/$DYNV6_DNS.key"

sleep 60
"$LOCAL_PATH/bin/nginx/nginx" -s reload



EOF
cat  "./cron.sh"
chmod +x "./cron.sh"



# nginx
cd "$LOCAL_PATH/bin"
if [ ! -d "nginx" ];then
curl -sSL -o  nginx.zip https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/nginx.zip
unzip  nginx.zip
rm nginx.zip

cd "$LOCAL_PATH/bin/nginx"
cat > "./conf/nginx.conf" <<EOF  


user  nobody;
worker_processes  2;

error_log  $LOCAL_PATH/bin/nginx/log/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       "$LOCAL_PATH/bin/nginx/conf/mime.types";
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  $LOCAL_PATH/bin/nginx/log/access.log  main;

    sendfile        on;
    client_max_body_size 1024M;
    keepalive_timeout  65;


    server {
        listen       $PORT ssl ;
        server_name  $DYNV6_DNS;

        root         "$LOCAL_PATH/bin/nginx/html";

        ssl_certificate     "$LOCAL_PATH/bin/nginx/conf/ssl/fullchain.cer";
        ssl_certificate_key "$LOCAL_PATH/bin/nginx/conf/ssl/$DYNV6_DNS.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;


     location / {
        proxy_set_header HOST $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_pass http://127.0.0.1:5244;
        }

    }

}


EOF
cat  "./conf/nginx.conf"

fi
chmod +x "./sbin/nginx"


ECC="_ecc"
mkdir -p "$LOCAL_PATH/bin/nginx/conf/ssl"
cp -f "$LOCAL_PATH/bin/acme/ssl/$DYNV6_DNS$ECC/fullchain.cer" "$LOCAL_PATH/bin/nginx/conf/ssl/fullchain.cer"
cp -f "$LOCAL_PATH/bin/acme/ssl/$DYNV6_DNS$ECC/$DYNV6_DNS.key" "$LOCAL_PATH/bin/nginx/conf/ssl/$DYNV6_DNS.key"


echo "ssl is ok"

}



# change ip for DYNV6_DNS
PUBLIC_IP=$(curl --silent http://4.ipw.cn)
echo "PUBLIC_IP is : $PUBLIC_IP"
curl --silent "https://ipv4.dynv6.com/api/update?zone=$DYNV6_DNS&ipv4=8.8.8.8&token=$DYNV6_TOKEN"
sleep 10
RESULT=$(curl --silent "https://ipv4.dynv6.com/api/update?zone=$DYNV6_DNS&ipv4=$PUBLIC_IP&token=$DYNV6_TOKEN")
echo "$RESULT"
if [ "$RESULT" == "addresses updated" ];then

SSL

else

BASH

fi



