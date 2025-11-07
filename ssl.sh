for ((i=1; i<=750; i++))
do
sleep 3600
done

export DYNV6_TOKEN="TOKEN0"
ECC="_ecc"
"HOME/bin/acme/acme.sh" --set-default-ca --issue --server letsencrypt --home "HOME/bin/acme/ssl" -d "DYNV6_DNS" --dns dns_dynv6  --debug  --force

sleep 60
mkdir -p "HOME/bin/nginx/conf/ssl"
cp -f "HOME/bin/acme/ssl/DYNV6_DNS$ECC/fullchain.cer" "HOME/bin/nginx/conf/ssl/fullchain.cer"
cp -f "HOME/bin/acme/ssl/DYNV6_DNS$ECC/DYNV6_DNS.key" "HOME/bin/nginx/conf/ssl/DYNV6_DNS.key"

sleep 60
"HOME/bin/nginx/sbin/nginx" -s reload

