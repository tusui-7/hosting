
# nginx
mkdir -p "/var/www/html"
mkdir -p "$PWD/bin/nginx/log"
mkdir -p "$PWD/bin/nginx/conf/ssl"
cp -ar "$PWD/bin/acme/ssl/$DYNV6_DNS$ECC/*" "$PWD/bin/nginx/conf/ssl"
cd "$PWD/bin/nginx"
if [ ! -f "./conf/nginx.conf" ];then
curl -sSL -o  nginx.tar.gz https://nginx.org/download/nginx-1.24.0.tar.gz
tar zxvf nginx.tar.gz
mv ./nginx-1.24.0/conf  .
rm -rf  nginx-1.24.0
rm nginx.tar.gz

cat > "./conf/nginx.conf" <<EOF  


user  nobody;
worker_processes  2;

error_log  $PWD/bin/nginx/log/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       "$PWD/bin/nginx/conf/mime.types";
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  $PWD/bin/nginx/log/access.log  main;

    sendfile        on;
    client_max_body_size 1024M;
    keepalive_timeout  65;


    server {
        listen       $PORT ssl ;
        server_name  $DYNV6_DNS;

        root         /var/www/html;

        ssl_certificate     "$PWD/bin/nginx/conf/ssl/fullchain.cer";
        ssl_certificate_key "$PWD/bin/nginx/conf/ssl/$DYNV6_DNS.key";
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

