#!/bin/bash

ECC="_ecc"
NAME="HOME/bin/acme/ssl/DYNV6_DNS$ECC/fullchain.cer"
DATE_CER=`ls -lh --time-style="+%Y-%m-%d"  "$NAME" | awk '{print $6}' `
echo $DATE_CER
let SEC_CER=$(date -d "$DATE_CER" +%s)
echo $SEC_CER

for ((i=1; i<=100; i++))
do

sleep 36000

DATE_NOW=`date +%Y-%m-%d`
echo $DATE_NOW

# 将日期转换为秒数
let SEC_NOW=$(date -d "$DATE_NOW" +%s)
echo $SEC_NOW

# 比较秒数
let SEC_OLD=$SEC_NOW-$SEC_CER
echo "$SEC_OLD"

if [ $SEC_OLD -gt 3000000 ]; then

echo "ok"
break
fi

done



export DYNV6_TOKEN="TOKEN0"

cd "HOME/bin/acme"
"./acme.sh" --set-default-ca --issue --server letsencrypt --home "./ssl" -d "DYNV6_DNS" --dns dns_dynv6  --debug  --force

sleep 60
if [ ! -d "HOME/bin/nginx/conf/ssl" ]; then
mkdir -p "HOME/bin/nginx/conf/ssl"
fi 
cp -f "HOME/bin/acme/ssl/DYNV6_DNS$ECC/fullchain.cer" "HOME/bin/nginx/conf/ssl/fullchain.cer"
cp -f "HOME/bin/acme/ssl/DYNV6_DNS$ECC/DYNV6_DNS.key" "HOME/bin/nginx/conf/ssl/DYNV6_DNS.key"

echo "" > "HOME/bin/nginx/logs/error.log"
echo "" > "HOME/bin/nginx/logs/access.log"

sleep 60
cd "HOME/bin/nginx/sbin"
"./nginx" -s reload


