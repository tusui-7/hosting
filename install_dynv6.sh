
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
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/$EXE_NAME/ssl.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


# acme.sh
mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME/ssl"
cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
if [ ! -f  "acme.sh" ];then

FILE_NAME="acme.tar.gz"
curl -sSL -o  "$FILE_NAME" https://github.com/acmesh-official/acme.sh/archive/master.tar.gz
tar zxvf "$FILE_NAME"
mv acme.sh-master/*  .
rm -rf  acme.sh-master
rm "$FILE_NAME"

export DYNV6_TOKEN="$DNS_TOKEN"
./acme.sh --set-default-ca --issue --server letsencrypt --home "./ssl" -d "$DNS_DOMAIN" -d "*.$DNS_DOMAIN" --dns dns_dynv6  --debug  --force

FILE_NAME="ssl.sh"
curl -sSL -o "$FILE_NAME"  "$DOWN_URL/sh/ssl_dynv6.sh"
sed -i "s|HOME|$LOCAL_PATH|g" "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g" "$FILE_NAME"

sed -i "s|DNS_TOKEN|$DNS_TOKEN|g" "$FILE_NAME"
# sed -i "s|DNS_Account_ID|$DNS_Account_ID|g" "$FILE_NAME"
# sed -i "s|DNS_ZONE_ID|$DNS_ZONE_ID|g" "$FILE_NAME"


chmod +x "./$FILE_NAME"

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
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/$EXE_NAME/sbin/nginx.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"
fi


# nginx
cd "$LOCAL_PATH/$BIN_PATH"
if [ ! -d "$EXE_NAME" ];then

FILE_NAME="nginx.zip"
curl -sSL -o  "$FILE_NAME" "$DOWN_URL/bin/nginx.zip"
unzip  "$FILE_NAME"
rm     "$FILE_NAME"
chmod +x "./$EXE_NAME/sbin/nginx"

cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME/conf"
FILE_NAME="nginx.conf"
mv "$FILE_NAME" "$FILE_NAME.$EXE_NAME"
curl -sSL -o "$FILE_NAME"  "$DOWN_URL/conf.d/nginx_http.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"
sed -i "s|443|$PORT|g"          "$FILE_NAME"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g" "$FILE_NAME"

#mkdir conf.d
mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME/conf/conf.d"

cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME/sbin"
FILE_NAME="nginx.sh"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/sh/nginx.sh"
sed -i "s|HOME|$LOCAL_PATH|g"    "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "$FILE_NAME"
chmod +x "./$FILE_NAME"

fi

#mkdir ssl
mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME/conf/ssl"
cp -f "$LOCAL_PATH/$BIN_PATH/acme/ssl/$DNS_DOMAIN$ECC/fullchain.cer" "$LOCAL_PATH/$BIN_PATH/$EXE_NAME/conf/ssl/fullchain.cer"
cp -f "$LOCAL_PATH/$BIN_PATH/acme/ssl/$DNS_DOMAIN$ECC/$DNS_DOMAIN.key" "$LOCAL_PATH/$BIN_PATH/$EXE_NAME/conf/ssl/$DNS_DOMAIN.key"


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
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"HOME/$BIN_PATH/$EXE_NAME/navidrome\", \n  \
  args: [\"--configfile\", \"HOME/$BIN_PATH/$EXE_NAME/navidrome.toml\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


# navidrome
mkdir -p "$LOCAL_PATH/file/music"
mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
cd  "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
if [ ! -f "$EXE_NAME" ];then

FILE_NAME="navidrome.tar.gz"
curl -sSL -o "$FILE_NAME"  https://github.com/navidrome/navidrome/releases/download/v0.58.0/navidrome_0.58.0_linux_amd64.tar.gz
tar -zxvf "$FILE_NAME"
rm        "$FILE_NAME"
chmod +x navidrome

FILE_NAME="navidrome.toml"
curl -sSL -o "$FILE_NAME"  "$DOWN_URL/conf/navidrome.toml"
sed -i "s|HOME|$LOCAL_PATH|g"    "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "$FILE_NAME"

fi


#navidrome.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then

cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
FILE_NAME="navidrome.conf"
curl -sSL -o "$FILE_NAME"  "$DOWN_URL/conf.d/navidrome.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"
sed -i "s|443|$PORT|g"          "$FILE_NAME"
sed -i "s|DNS_NAME|$SUB_NAVIDROME|g"  "$FILE_NAME"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g"   "$FILE_NAME"


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
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"HOME/$BIN_PATH/$EXE_NAME/filebrowser\", \n  \
  args: [\"-c\", \"HOME/$BIN_PATH/$EXE_NAME/.config.json\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
if [ ! -f "$EXE_NAME" ];then

FILE_NAME="filebrowser.zip"
curl -sSL -o  "$FILE_NAME" "$DOWN_URL/bin/filebrowser.zip"
unzip  "$FILE_NAME"
rm     "$FILE_NAME"
chmod +x "./filebrowser"

FILE_NAME=".config.json"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/conf/filebrowser.json"
sed -i "s|HOME|$LOCAL_PATH|g" "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"

fi

#filebrowser.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then

cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
FILE_NAME="filebrowser.conf"
curl -sSL -o "$FILE_NAME"  "$DOWN_URL/conf.d/filebrowser.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"
sed -i "s|443|$PORT|g"          "$FILE_NAME"
sed -i "s|DNS_NAME|$SUB_FILEBROWSER|g"  "$FILE_NAME"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g"     "$FILE_NAME"

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
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"HOME/$BIN_PATH/$EXE_NAME/openlist\", \n  \
  args: [\"server\", \"--data=HOME/$BIN_PATH/$EXE_NAME\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
if [ ! -f "$EXE_NAME" ];then

FILE_NAME="openlist.tar.gz"
curl -sSL -o  "$FILE_NAME" https://github.com/OpenListTeam/OpenList/releases/download/v4.0.9/openlist-linux-amd64-lite.tar.gz
tar -zxvf "$FILE_NAME"
rm        "$FILE_NAME"
chmod +x  "./openlist"

FILE_NAME="config.json"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/conf/openlist.json"
sed -i "s|HOME|$LOCAL_PATH|g" "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"

fi

#openlist.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then

cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
FILE_NAME="openlist.conf"
curl -sSL -o "$FILE_NAME"  "$DOWN_URL/conf.d/openlist.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"
sed -i "s|443|$PORT|g"          "$FILE_NAME"
sed -i "s|DNS_NAME|$SUB_OPENLIST|g"  "$FILE_NAME"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g"  "$FILE_NAME"

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
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/$EXE_NAME/easytier.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi


mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
if [ ! -f "$EXE_NAME" ];then

FILE_NAME="easytier.zip"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/bin/easytier.zip"
unzip   "$FILE_NAME"
rm      "$FILE_NAME"
chmod +x "./easytier"

FILE_NAME="easytier.sh"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/sh/easytier.sh"
sed -i "s|HOME|$LOCAL_PATH|g"    "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "$FILE_NAME"
sed -i "s|SECERT_EASYTIER|$SECERT_EASYTIER|g"  "$FILE_NAME"

chmod +x "./$FILE_NAME"

fi

#easytier.conf
if [ -d "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d" ];then

cd "$LOCAL_PATH/$BIN_PATH/nginx/conf/conf.d"
FILE_NAME="easytier.conf"
curl -sSL -o "$FILE_NAME"  "$DOWN_URL/conf.d/easytier.conf"
sed -i "s|HOME|$LOCAL_PATH|g"   "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g" "$FILE_NAME"
sed -i "s|443|$PORT|g"          "$FILE_NAME"
sed -i "s|DNS_NAME|$SUB_EASYTIER|g"  "$FILE_NAME"
sed -i "s|DNS_DOMAIN|$DNS_DOMAIN|g"  "$FILE_NAME"

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
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"bash\", \n  \
  args: [\"HOME/$BIN_PATH/$EXE_NAME/hbbr.sh\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi

mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
if [ ! -f "hbbr" ];then

FILE_NAME="hbbr.zip"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/bin/hbbr.zip"
unzip   "$FILE_NAME"
rm      "$FILE_NAME"
chmod +x "./hbbr"

FILE_NAME="hbbr.sh"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/sh/hbbr.sh"
sed -i "s|HOME|$LOCAL_PATH|g"    "$FILE_NAME"
sed -i "s|BIN_PATH|$BIN_PATH|g"  "$FILE_NAME"

chmod +x "./$FILE_NAME"

fi

echo "$EXE_NAME is ok"

}







#frpc
function  FRPC()
{

EXE_NAME="frpc"
cd  "$LOCAL_PATH/"
if grep -q "$EXE_NAME" "$INDEX_JS"; then
echo "Found $EXE_NAME"
else

sed -i "$SED_FLAGS/a  \
  \  { \n  \
  name: \"$EXE_NAME\", \n  \
  binaryPath: \"HOME/$BIN_PATH/$EXE_NAME/frpc\", \n  \
  args: [\"-c\", \"HOME/$BIN_PATH/$EXE_NAME/frpc.toml\"], \n  \
  mode: \"inherit\" \n  \
 }, \n  " "$INDEX_JS"

sed -i "s|HOME|$LOCAL_PATH|g" "$INDEX_JS"

fi

mkdir -p "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
cd "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
if [ ! -f "frpc" ];then

FILE_NAME="frpc.zip"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/bin/frpc.zip"
unzip   "$FILE_NAME"
rm      "$FILE_NAME"
chmod +x "./frpc"

FILE_NAME="frpc.toml"
curl -sSL -o  "$FILE_NAME"  "$DOWN_URL/conf/frpc.toml"

echo ---------------------------
echo  frpc.toml files in:
echo "$LOCAL_PATH/$BIN_PATH/$EXE_NAME"
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









function  GET_DYNV6()
{
if [ -n  "$DNS_TOKEN" ];then

ZONE=$(curl -s -X GET \
    -H "Authorization: Bearer $DNS_TOKEN" \
    -H "Accept: application/json" \
    https://dynv6.com/api/v2/zones  \
)
sleep 5
echo "$ZONE"

ARRAY_ZONES=(`echo "$ZONE" | tr '}' ' ' ` )  
for VAR_ZONE in ${ARRAY_ZONES[@]}
do

echo  "$VAR_ZONE"
if  echo "$VAR_ZONE"| grep -c  "\"name\":\"${DNS_DOMAIN}\"" ;then

ARRAY_VARs=(`echo "$VAR_ZONE" |tr ',' ' ' `)
for VAR_C in ${ARRAY_VARs[@]}
do

echo $VAR_C
if  echo "${VAR_C}"| grep -c  "id" ;then

VAR_Cs=(`echo "$VAR_C"|tr ':' ' ' `)
echo  "${VAR_Cs[0]}"
echo  "${VAR_Cs[1]}"
DNS_ZONE_ID="${VAR_Cs[1]}"
break
fi

done

break
fi

done 

echo DNS_ZONE_ID is $DNS_ZONE_ID
# echo DNS_DOMAIN is $DNS_DOMAIN

fi

}




function  DYNV6_IP()
{

if [ -n "$1" ];then

NAMES="$1"
echo ${NAMES}

data="{  \
    \"name\": \"${NAMES}\",       \
    \"data\": \"${PUBLIC_IP}\",  \
    \"type\": \"A\"    \
	}"
echo "${data}"


ZONE=$(curl -s -X GET  -H "Authorization: Bearer ${DNS_TOKEN}"  -H "Accept: application/json"  https://dynv6.com/api/v2/zones/${DNS_ZONE_ID}/records )
echo "$ZONE"

recordID=''
ARRAY_ZONES=(`echo "$ZONE" | tr '}' ' ' ` )  
for VAR_ZONE in ${ARRAY_ZONES[@]}
do

echo  "$VAR_ZONE"
if  echo "$VAR_ZONE"| grep -c  "\"name\":\"${NAMES}\"" ;then

ARRAY_VARs=(`echo "$VAR_ZONE" |tr ',' ' ' `)
for VAR_C in ${ARRAY_VARs[@]}
do

echo $VAR_C
if  echo "${VAR_C}"| grep -c  "id" ;then

VAR_Cs=(`echo "$VAR_C"|tr ':' ' ' `)
echo  "${VAR_Cs[0]}"
echo  "${VAR_Cs[1]}"
recordID="${VAR_Cs[1]}"
break
fi

done

break
fi

done 
	
echo $recordID


if [ -n "$recordID" ];then

RESULT=$(curl -s -X PATCH  \
    -H "Authorization: Bearer ${DNS_TOKEN}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
	--data  "${data}"  \
    "https://dynv6.com/api/v2/zones/${DNS_ZONE_ID}/records/${recordID}"  \
)  
else
RESULT=$(curl -s -X POST  \
    -H "Authorization: Bearer $DNS_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
	--data  "${data}"  \
    "https://dynv6.com/api/v2/zones/${DNS_ZONE_ID}/records"  \
)

fi

echo "更新结果: $RESULT"

fi

}





function  MAIN()
{

# get the package.json
cd  "$LOCAL_PATH/"
curl -sSL -o package.json "$DOWN_URL/package.json"


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
echo DNS_TOKEN="XXXXXX" 
echo this must be dynv6 token
echo if dynv6 token zone is all,
echo you must make DNS_DOMAIN="XXX" 
echo --------------------------------
sleep 5
echo ''
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
echo 'curl -s https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/install_dynv6.sh |'
echo 'env PORT=12345 DNS_TOKEN="XXXXXX" OPENLIST_FLAG="true" SUB_OPENLIST="op"  bash'
echo ''
echo --------------------------------
echo ' if not have a domain'
echo ''
echo 'curl -s https://raw.githubusercontent.com/tusui-7/hosting/refs/heads/main/install_dynv6.sh |'
echo 'env PORT=12345  OPENLIST_FLAG="true" bash'
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

GET_DYNV6
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

DYNV6_IP "$SUB_NAVIDROME"

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
DYNV6_IP "$SUB_FILEBROWSER"

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
DYNV6_IP "$SUB_OPENLIST"

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
DYNV6_IP "$SUB_EASYTIER"

fi

fi


#frpc
if [ "$FRPC_FLAG" == "true" ];then
FPRC

fi


}





MAIN




