PUBLIC_IP=$(curl --silent http://4.ipw.cn)
curl "https://ipv4.dynv6.com/api/update?zone=$DYNV6_DNS&ipv4=8.8.8.8&token=$DYNV6_TOKEN"
curl "https://ipv4.dynv6.com/api/update?zone=$DYNV6_DNS&ipv4=$PUBLIC_IP&token=$DYNV6_TOKEN"

