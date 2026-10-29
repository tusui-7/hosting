#!/bin/bash

ECC="_ecc"
NAME="HOME/BIN_PATH/acme/ssl/DNS_DOMAIN$ECC/fullchain.cer"
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





cd "HOME/BIN_PATH/acme"
if [ ! -d "HOME/BIN_PATH/nginx/conf/ssl" ]; then
mkdir -p "HOME/BIN_PATH/nginx/conf/ssl"
fi 


CF_Token="DNS_TOKEN"
CF_Account_ID="DNS_Account_ID"
CF_Zone_ID="DNS_ZONE_ID"
./acme.sh --set-default-ca --issue --server letsencrypt --home "./ssl" -d "$DNS_DOMAIN" -d "*.$DNS_DOMAIN" --dns dns_cf  --debug  --force


sleep 60

cp -f "HOME/BIN_PATH/acme/ssl/DNS_DOMAIN$ECC/fullchain.cer" "HOME/BIN_PATH/nginx/conf/ssl/fullchain.cer"
cp -f "HOME/BIN_PATH/acme/ssl/DNS_DOMAIN$ECC/DNS_DOMAIN.key" "HOME/BIN_PATH/nginx/conf/ssl/DNS_DOMAIN.key"

echo "" > "HOME/BIN_PATH/nginx/logs/error.log"
echo "" > "HOME/BIN_PATH/nginx/logs/access.log"

sleep 60
cd "HOME/BIN_PATH/nginx/sBIN_PATH"
"./nginx" -s reload


