

echo "$PWD"

# cd "$PWD/bin/nginx/sbin/"
# useradd nginx -s /sbin/nologin  -M

cd "HOME/BIN_PATH/nginx/sbin/"
./nginx  -g "daemon off;"

sleep 10