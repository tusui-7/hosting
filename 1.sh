# nginx

LOCAL_PATH="$PWD"


mkdir -p "$LOCAL_PATH/bin/nginx"
cd "$LOCAL_PATH/bin/nginx"
if [ ! -f "./conf/nginx.conf" ];then
curl -sSL -o  nginx.zip https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/nginx.zip
unzip  nginx.zip
rm nginx.zip

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
chmod +x "./nginx/nginx"


ECC="_ecc"
mkdir -p "$LOCAL_PATH/bin/nginx/conf/ssl"
cp -ar "$LOCAL_PATH/bin/acme/ssl/$DYNV6_DNS$ECC/*" "$LOCAL_PATH/bin/nginx/conf/ssl"


echo "ssl is ok"
