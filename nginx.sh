

echo "$PWD"

cd "$PWD/bin/nginx/sbin/"

#useradd nginx -s /sbin/nologin  -M
./nginx  -g "daemon off;"

