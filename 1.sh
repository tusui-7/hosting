
export DYNV6_TOKEN="x6onnai7W_n6RqEz1JUgYX3NWSzPnz"
export DYNV6_DNS="musics.v6.navy"



mkdir -p "$PWD/bin/acme"

cd "$PWD/bin/acme"
curl -sSL -o  acme.tar.gz https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
tar zxvf acme.tar.gz
mv acme.sh-master/*  .
rm -rf  acme.sh-master
rm acme.tar.gz

./acme.sh --install --nocron --home "$PWD/bin/acme/ssl" --accountemial "XX@email.com"

./acme.sh --issue --server letsencrypt --home . -d "$DYNV6_DNS" --dns dns_dynv6



