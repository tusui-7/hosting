
mkdir -p "$PWD/bin/acme/ssl"
cd "$PWD/bin/acme"
if [ ! -f acme.sh ];then
curl -sSL -o  acme.tar.gz https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
tar zxvf acme.tar.gz
mv acme.sh-master/*  .
rm -rf  acme.sh-master
rm acme.tar.gz
fi

# ./acme.sh --install --nocron --home "$PWD/bin/acme/ssl"  -s  "email=XX@email.com"
./acme.sh --set-default-ca --issue --server letsencrypt --home "./ssl" -d "$DYNV6_DNS" --dns dns_dynv6  --debug  --force


