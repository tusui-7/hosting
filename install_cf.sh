
#!/usr/bin/env sh

LOCAL_PATH="$PWD"
BIN_PATH="${BIN_PATH:-bins}"
ECC="_ecc"
SED_FLAGS="/\/\/SED_ADD_INSERT"
INDEX_JS="${INDEX_JS:-index.js}"
mkdir -p "$LOCAL_PATH/$BIN_PATH"

# dns_name
SUB_NAVIDROME="${SUB_NAVIDROME:-navidrome}"
SUB_FILEBROWSER="${SUB_FILEBROWSER:-filebrowser}"
SUB_OPENLIST="${SUB_OPENLIST:-openlist}"
SUB_EASYTIER="${SUB_EASYTIER:-easytier}"

# secert_easytier
SECERT_EASYTIER="${SECERT_EASYTIER:-orihost}"

# down_url
DOWN_URL="${DOWN_URL:-https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main}"

#token
PORT="${PORT:-4533}"
DNS_TOKEN="${DNS_TOKEN:-123}"
DNS_DOMAIN="${DNS_DOMAIN:-123}"
DNS_ZONE_ID=''
DNS_Account_ID=''
DNS_EMAIL=''

	
#get ip
PUBLIC_IP=$(curl --silent https://api-ipv4.ip.sb/ip)
echo "PUBLIC_IP is : $PUBLIC_IP"	






function  ACME()
{

EXE_NAME="acme"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"acme\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/acme/ssl.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


# acme.sh
mkdir -p "$LOCAL_PATH/$BIN_PATH/acme/ssl"
cd "$LOCAL_PATH/$BIN_PATH/acme"
if [ ! -f  "$EXE_NAME.sh" ];then
curl -sSL -o  acme.tar.gz https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
tar zxvf acme.tar.gz
mv acme.sh-master/*  .
rm -rf  acme.sh-master
rm acme.tar.gz

export CF_Token="$DNS_TOKEN"
export CF_Account_ID="$DNS_Account_ID"
export CF_Zone_ID="$DNS_ZONE_ID"
./acme.sh --set-default-ca --issue --server letsencrypt --home "./ssl" -d "$DNS_DOMAIN" -d "*.$DNS_DOMAIN" --dns dns_cf  --debug  --force

curl -sSL -o ssl.sh  "$DOWN_URL/sh/ssl_cf.sh"
sed -i "s|HOME|$LOCAL_PATH|g" ssl.sh
sed -i "s|BIN_PATH|$BIN_PATH|g" ssl.sh
sed -i "s|DNS_TOKEN|$DNS_TOKEN|g" ssl.sh
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g" ssl.sh
sed -i "s|DNS_Account_ID|$DNS_Account_ID|g" ssl.sh
sed -i "s|DNS_ZONE_ID|$DNS_ZONE_ID|g" ssl.sh


chmod +x "./ssl.sh"

fi

echo "$EXE_NAME is ok"

}



function  NGINX()
{

EXE_NAME="nginx"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"nginx\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/nginx/sbin/nginx.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"
fi


# nginx
cd "$LOCAL_PATH/$BIN_PATH"
if [ ! -d "$EXE_NAME" ];then
curl -sSL -o  nginx.zip "$DOWN_URL/bin/nginx.zip"
unzip  nginx.zip
rm nginx.zip
chmod +x "./nginx/sbin/nginx"

cd "$LOCAL_PATH/$BIN_PATH/nginx/conf"
mv nginx.conf "nginx.conf.$EXE_NAME"
curl -sSL -o nginx.conf  "$DOWN_URL/conf.d/nginx_http.conf"
sed -i "s|HOME|$LOCAL_PATH|g" "nginx.conf"
sed -i "s|BIN_PATH|$BIN_PATH|g" "nginx.conf"
sed -i "s|443|$PORT|g"        "nginx.conf"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g" "nginx.conf"

#mkdir conf.d
mkdir -p "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"

cd "$LOCAL_PATH/$BIN_PATH/nginx/sbin"
curl -sSL -o  nginx.sh  "$DOWN_URL/sh/nginx.sh"
sed -i "s|HOME|$LOCAL_PATH|g" "nginx.sh"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "nginx.sh"
chmod +x "./nginx.sh"

fi

#nkdir ssl
mkdir -p "$LOCAL_PATH/$BIN_PATH/nginx/conf/ssl"
cp -f "$LOCAL_PATH/$BIN_PATH/acme/ssl/$DNS_DOMAIN$ECC/fullchain.cer" "$LOCAL_PATH/$BIN_PATH/nginx/conf/ssl/fullchain.cer"
cp -f "$LOCAL_PATH/$BIN_PATH/acme/ssl/$DNS_DOMAIN$ECC/$DNS_DOMAIN.key" "$LOCAL_PATH/$BIN_PATH/nginx/conf/ssl/$DNS_DOMAIN.key"


echo "$EXE_NAME is ok"

}



function  NAVIDROME()
{

EXE_NAME="navidrome"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"navidrome\", \n  \
  binaryPath: \"HOME/$BIN_PATH/navidrome/navidrome\", \n  \
  args: [\"--configfile\", \"HOME/$BIN_PATH/navidrome/navidrome.toml\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


# navidrome
mkdir -p "$LOCAL_PATH/file/music"
mkdir -p "$LOCAL_PATH/$BIN_PATH/navidrome"
cd  "$LOCAL_PATH/$BIN_PATH/navidrome"
if [ ! -f "$EXE_NAME" ];then
curl -sSL -o navidrome.tar.gz  https://github.com/navidrome/navidrome/releases/download/v0.58.0/navidrome_0.58.0_linux_amd64.tar.gz
tar -zxvf navidrome.tar.gz
chmod +x navidrome
rm navidrome.tar.gz

curl -sSL -o navidrome.toml  "$DOWN_URL/conf/navidrome.toml"
sed -i "s|HOME|$LOCAL_PATH|g"  "navidrome.toml"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "navidrome.toml"

fi


#navidrome.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then

cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
curl -sSL -o navidrome.conf  "$DOWN_URL/conf.d/navidrome.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "navidrome.conf"
sed -i "s|BIN_PATH|$BIN_PATH|g" "navidrome.conf"
sed -i "s|443|$PORT|g"          "navidrome.conf"
sed -i "s|DNS_NAME|$SUB_NAVIDROME|g"  "navidrome.conf"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g" "navidrome.conf"


fi

echo "$EXE_NAME is ok"

}





# filebrowser
function  FILEBROWSER()
{

EXE_NAME="filebrowser"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"filebrowser\", \n  \
  binaryPath: \"HOME/$BIN_PATH/filebrowser/filebrowser\", \n  \
  args: [\"-c\", \"HOME/$BIN_PATH/filebrowser/.config.json\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/filebrowser"
cd "$LOCAL_PATH/$BIN_PATH/filebrowser"
if [ ! -f "$EXE_NAME" ];then
curl -sSL -o  filebrowser.zip "$DOWN_URL/bin/filebrowser.zip"
unzip  filebrowser.zip
rm filebrowser.zip
chmod +x "./filebrowser"

curl -sSL -o  .config.json  "$DOWN_URL/conf/filebrowser.json"
sed -i "s|HOME|$LOCAL_PATH|g" ".config.json"
sed -i "s|BIN_PATH|$BIN_PATH|g" ".config.json"

fi

#filebrowser.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then
cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
curl -sSL -o filebrowser.conf  "$DOWN_URL/conf.d/filebrowser.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "filebrowser.conf"
sed -i "s|BIN_PATH|$BIN_PATH|g" "filebrowser.conf"
sed -i "s|443|$PORT|g"          "filebrowser.conf"
sed -i "s|DNS_NAME|$SUB_FILEBROWSER|g"  "filebrowser.conf"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g"  "filebrowser.conf"

fi

echo "$EXE_NAME is ok"

}


#openlist
function  OPENLIST()
{

EXE_NAME="openlist"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"openlist\", \n  \
  binaryPath: \"HOME/$BIN_PATH/openlist/openlist\", \n  \
  args: [\"server\", \"--data=HOME/$BIN_PATH/openlist\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/openlist"
cd "$LOCAL_PATH/$BIN_PATH/openlist"
if [ ! -f "$EXE_NAME" ];then

curl -sSL -o  openlist.tar.gz https://github.com/OpenListTeam/OpenList/releases/download/v4.0.9/openlist-linux-amd64-lite.tar.gz
tar -zxvf openlist.tar.gz
rm openlist.tar.gz
chmod +x "./openlist"

curl -sSL -o  config.json  "$DOWN_URL/conf/openlist.json"
sed -i "s|HOME|$LOCAL_PATH|g" "config.json"
sed -i "s|BIN_PATH|$BIN_PATH|g" "config.json"

fi

#openlist.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then
cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
curl -sSL -o openlist.conf  "$DOWN_URL/conf.d/openlist.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "openlist.conf"
sed -i "s|BIN_PATH|$BIN_PATH|g" "openlist.conf"
sed -i "s|443|$PORT|g"          "openlist.conf"
sed -i "s|DNS_NAME|$SUB_OPENLIST|g"  "openlist.conf"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g" "openlist.conf"

fi

echo "$EXE_NAME is ok"

}


#easytier
function  EASYTIER()
{

EXE_NAME="easytier"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"easytier\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/easytier/easytier.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/easytier"
cd "$LOCAL_PATH/$BIN_PATH/easytier"
if [ ! -f "$EXE_NAME" ];then

curl -sSL -o  easytier.zip  "$DOWN_URL/bin/easytier.zip"
unzip   easytier.zip
rm   easytier.zip
chmod +x "./easytier"


curl -sSL -o  easytier.sh  "$DOWN_URL/sh/easytier.sh"
sed -i "s|HOME|$LOCAL_PATH|g" "easytier.sh"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "easytier.sh"
sed -i "s|SECERT_EASYTIER|$SECERT_EASYTIER|g"  "easytier.sh"

chmod +x "./easytier.sh"

fi

#easytier.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then
cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
curl -sSL -o easytier.conf  "$DOWN_URL/conf.d/easytier.conf"
sed -i "s|HOME|$LOCAL_PATH|g" "easytier.conf"
sed -i "s|BIN_PATH|$BIN_PATH|g" "easytier.conf"
sed -i "s|443|$PORT|g"        "easytier.conf"
sed -i "s|DNS_NAME|$SUB_EASYTIER|g"  "easytier.conf"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g" "easytier.conf"

fi

echo "$EXE_NAME is ok"

}





#hbbr
function  HBBR()
{

EXE_NAME="hbbr"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"hbbr\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/hbbr/hbbr.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/hbbr"
cd "$LOCAL_PATH/$BIN_PATH/hbbr"
if [ ! -f "hbbr" ];then

curl -sSL -o  hbbr.zip  "$DOWN_URL/bin/hbbr.zip"
unzip   hbbr.zip
rm   hbbr.zip
chmod +x "./hbbr"

curl -sSL -o  hbbr.sh  "$DOWN_URL/sh/hbbr.sh"
sed -i "s|HOME|$LOCAL_PATH|g" "hbbr.sh"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "hbbr.sh"

chmod +x "./hbbr.sh"

fi

echo "$EXE_NAME is ok"

}







#frpc
function  FPRC()
{

EXE_NAME="fprc"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"HOME/$BIN_PATH/frpc/frpc\", \n  \
  args: [\"-c\", \"HOME/$BIN_PATH/frpc/frpc.toml\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/frpc"
cd "$LOCAL_PATH/$BIN_PATH/frpc"
if [ ! -f "frpc" ];then

curl -sSL -o  hbbr.zip  "$DOWN_URL/bin/frpc.zip"
unzip   frpc.zip
rm   frpc.zip
chmod +x "./frpc"

curl -sSL -o  frpc.toml  "$DOWN_URL/conf/frpc.toml"

echo ---------------------------
echo  frpc.toml files in:
echo "$LOCAL_PATH/$BIN_PATH/frpc"
echo you must change your config 
echo more config of frpc.toml is
echo ''
echo "$DOWN_URL/conf/frpc.toml.example"
echo ''
echo wait 5s and continue
echo ---------------------------
sleep 5

fi


echo "$EXE_NAME is ok"

}







function  GET_CF()
{
if [ -n  "$DNS_TOKEN" ];then

# get account id 
ZONE_IDs=$(curl -X GET "https://api.cloudflare.com/client/v4/accounts" \
-H "Authorization: Bearer $DNS_TOKEN" \
-H "Content-Type: application/json" \
)
echo "$ZONE_IDs"

ARRAY_ZONES=(`echo "$ZONE_IDs" | tr ',' ' '` )  
for VAR_ZONE in ${ARRAY_ZONES[@]}
do

echo  "$VAR_ZONE"
VARs=(`echo "$VAR_ZONE" | grep "id"|tr ':' ' ' `)
echo  "${VARs[0]}"
echo  "${VARs[1]}"
echo  "${VARs[2]}"
if [ -n "${VARs[2]}" ];then
DNS_Account_ID="${VARs[2]}"
DNS_Account_ID="${DNS_Account_ID//\"/}"
fi

echo  "$VAR_ZONE"
VARs=(`echo "$VAR_ZONE" | grep "name"|tr ':' ' ' `)
echo  "${VARs[0]}"
echo  "${VARs[1]}"
if [ -n "${VARs[1]}" ];then
DNS_EMAIL="${VARs[1]}"
DNS_EMAIL="${DNS_EMAIL//\"/}"
DNS_EMAIL="${DNS_EMAIL%??}"
fi

done 
	
echo DNS_Account_ID is $DNS_Account_ID
echo DNS_EMAIL is $DNS_EMAIL

# get zone id
ZONE_NAME="$DNS_DOMAIN"
ZONE=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME" \
-H "X-Auth-Email: $DNS_EMAIL" \
-H "Authorization: Bearer $DNS_TOKEN" \
-H "Content-Type: application/json" \
)
echo "$ZONE"


ARRAY_ZONES=(`echo "$ZONE" | tr ',' ' '` )  
for VAR_ZONE in ${ARRAY_ZONES[@]}
do

echo  "$VAR_ZONE"
VARs=(`echo "$VAR_ZONE" | grep "id"|tr ':' ' ' `)
echo  "${VARs[0]}"
echo  "${VARs[1]}"
echo  "${VARs[2]}"
if [ -n "${VARs[2]}" ];then
DNS_ZONE_ID="${VARs[2]}"
DNS_ZONE_ID="${DNS_ZONE_ID//\"/}"
break
fi

done 
	
echo DNS_ZONE_ID is $DNS_ZONE_ID

fi

}


function  CF_IP()
{

if [ -n "$1" ];then

NAMES="$1"
echo ${NAMES}

data="{\"type\":\"A\",  \
      \"name\":\"${NAMES}\",  \
	  \"content\":\"${PUBLIC_IP}\", \
	  \"ttl\":60, \
	  \"proxied\":false \
	  }"
echo "${data}"

RECORD_IDs=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${DNS_ZONE_ID}/dns_records?name=${NAMES}.${DNS_DOMAIN}")
let RESULT=$(echo $RECORD_IDs|grep -c '"success":false')
if [ $RESULT -eq 0 ];then

echo  "$RECORD_IDs"
ARRAY_ZONES=(`echo "$RECORD_IDs" | tr ',' ' '` )  
for VAR_ZONE in ${ARRAY_ZONES[@]}
do

echo  "$VAR_ZONE"
VARs=(`echo "$VAR_ZONE" | grep "id"|tr ':' ' ' `)
echo  "${VARs[0]}"
echo  "${VARs[1]}"
echo  "${VARs[2]}"
if [ -n "${VARs[2]}" ];then
RECORD_ID="${VARs[2]}"
RECORD_ID="${RECORD_ID//\"/}"
break
fi

done 
	
echo RECORD_ID is $RECORD_ID
RESULT=$(curl  -s -X PUT "https://api.cloudflare.com/client/v4/zones/${DNS_ZONE_ID}/dns_records/${RECORD_ID}" \
-H "Content-Type: application/json" \
-H "X-Auth-Email: $DNS_EMAIL" \
-H "Authorization: Bearer $DNS_TOKEN" \
--data  "${data}" )  
else

RESULT=$(curl  -s -X POST "https://api.cloudflare.com/client/v4/zones/${DNS_ZONE_ID}/dns_records" \
-H "Content-Type: application/json" \
-H "X-Auth-Email: $DNS_EMAIL" \
-H "Authorization: Bearer $DNS_TOKEN" \
--data  "${data}" )  

fi

echo "更新结果: $RESULT"

fi

}





function  MAIN()
{

# get the package.json
cd  "$LOCAL_PATH/"
curl -sSL -o package.json $DOWN_URL/package.json


echo --------------------------------
echo Notice : only One port
echo must PORT="yourport"
echo --------------------------------
echo if you do not have a domain,
echo you only can run one of blows:
echo ------------
echo filebrower,
echo navidrome,
echo easytier,
echo openlist,
echo hbbr,
echo -------------
echo and future apps.
echo --------------------------------
echo but frpc can work well,
echo nginx and hbbr cant work together
echo --------------------------------
sleep 5
echo ''
echo --------------------------------
echo you want one app, you must make 
echo APPNAME_FLAG="true" ,
echo for example, OPENLIST_FLAG="true" 
echo --------------------------------
echo easytier secert is "orihost"
echo if change it, must make
echo SECERT_EASYTIER="yoursecert",
echo --------------------------------
sleep 5
echo ''
echo --------------------------------
echo if you  have a domain, must make
echo DNS_TOKEN="XXXXXX" and
echo DNS_DOMAIN="example.com"
echo this must be cf token and domain
echo --------------------------------
echo subdomain name is app name self,
echo if you want to change subdomain name,
echo must make SUB_APPNAME="name" ,
echo for example, SUB_OPENLIST="op"
echo --------------------------------
sleep 5
echo ''
echo ''
echo --------------------------------
echo you can run in bash,for example:
echo ''
echo 'curl -s https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/install_cf.sh |'
echo 'env PORT=12345 DNS_TOKEN="XXXXXX" DNS_DOMAIN="example.com" EASYTIER_FLAG="true" SUB_EASYTIER="es" SECERT_EASYTIER="secert" bash'
echo ''
echo --------------------------------
echo ' if not have a domain'
echo ''
echo 'curl -s https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/install_cf.sh |'
echo 'env PORT=12345  EASYTIER_FLAG="true" SECERT_EASYTIER="secert" bash'
echo ''
echo wait 5s and continue
echo --------------------------------
sleep 5



#HBBR 
if [ "$HBBR_FLAG" == "true" ];then

echo --------------------------------
echo if you use hbbr:
echo the port will be used for it,
echo nginx cant work and close.
echo so DNS_TOKEN change to null
echo other apps can work with frpc
echo you can config FRPC_FLAG=true
echo wait 5s and continue
echo --------------------------------
sleep 5

DNS_TOKEN=""
HBBR


sed -i "s|21117|$PORT|g" "$LOCAL_PATH/$BIN_PATH/hbbr/hbbr.sh"

cd "$LOCAL_PATH"
if grep -q "nginx" "$INDEX_JS"; then

CHANGE="\.\/nginx.*"
CHANGE_TO="\#\.\/nginx  -g \"daemon off;\""
sed -ir "s|$CHANGE|$CHANGE_TO|g" \
"$LOCAL_PATH/$BIN_PATH/nginx/sbin/nginx.sh"

fi

fi


# change ip for DNS_DOMAIN
sleep 2
if [ -n  "$DNS_TOKEN" ];then

GET_CF
echo "DNS_DOMAIN is :$DNS_DOMAIN"

if [  -n  "$DNS_DOMAIN" ];then

ACME
NGINX

echo --------------------------------
echo if you are running hbbr,
echo nginx cant work with hbbr,
echo the port will be used for it,
echo hbbr cant work and change port.
echo so hbbr port change to 21117
echo wait 5s and continue
echo --------------------------------
sleep 5

# nginx on
cd "$LOCAL_PATH"
if grep -q "nginx" "$INDEX_JS"; then

CHANGE="\#\.\/nginx.*"
CHANGE_TO="\.\/nginx  -g \"daemon off;\""
sed -ir "s|$CHANGE|$CHANGE_TO|g" \
"$LOCAL_PATH/$BIN_PATH/nginx/sbin/nginx.sh"

fi

if grep -q "hbbr" "$INDEX_JS"; then

CHANGE="\[\"-p\",.*\"\]"
CHANGE_TO="[\"-p\", \"21117\"]"
sed -ir "s|$CHANGE|$CHANGE_TO|g"  "$LOCAL_PATH/$BIN_PATH/hbbr/hbbr.sh"

fi


fi
fi



#navidrome
if [ "$NAVIDROME_FLAG" == "true" ];then

NAVIDROME

if [ ! -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then
cd  "$LOCAL_PATH/$BIN_PATH/navidrome"
sed -i "s|4533|$PORT|g" "navidrome.toml"
exit

else

CF_IP "$SUB_NAVIDROME"

fi

fi


#filebrowser
if [ "$FILEBROWSER_FLAG" == "true" ];then

FILEBROWSER

if [ ! -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then
cd "$LOCAL_PATH/$BIN_PATH/filebrowser"
sed -i "s|8081|$PORT|g" ".config.json"
exit

else
CF_IP "$SUB_FILEBROWSER"

fi

fi


#OPENLIST
if [ "$OPENLIST_FLAG" == "true" ];then

OPENLIST

if [ ! -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then
cd "$LOCAL_PATH/$BIN_PATH/openlist"
sed -i "s|5244|$PORT|g" "config.json"
exit

else
CF_IP "$SUB_OPENLIST"

fi

fi


#EASYTIER
if [ "$EASYTIER_FLAG" == "true" ];then

EASYTIER

if [ ! -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then
cd "$LOCAL_PATH/$BIN_PATH/easytier"
sed -i "s|1102|$PORT|g" "easytier.sh"
exit

else
CF_IP "$SUB_EASYTIER"

fi

fi

#frpc
if [ "$FRPC_FLAG" == "true" ];then
FRPC

fi

}





MAIN




