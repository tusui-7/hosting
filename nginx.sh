

echo "$PWD"

# cd "$PWD/bin/nginx/sbin/"
# useradd nginx -s /sbin/nologin  -M

cd "HOME/bin/nginx/sbin/"
./nginx  -g "daemon off;"

