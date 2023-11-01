#!/bin/bash

# Replace with your domain and email
DOMAIN=$1
EMAIL=$3
CERT_PATH="/etc/letsencrypt/live/$1"
PKCS12_PASSWORD=$2

# Check if Certbot is installed, and install it if necessary
sudo apt-get update
sudo apt-get install certbot python3-certbot-apache -y

sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

sudo lsof -i :80 | awk 'NR>1 {print $2}' | xargs sudo kill

#sudo python3 -m http.server 80 &


# Request or renew the certificate
sudo certbot certonly --noninteractive --agree-tos --email $EMAIL -d $DOMAIN --standalone

sudo openssl pkcs12 -export -out $DOMAIN.p12 -inkey $CERT_PATH/privkey.pem -in $CERT_PATH/fullchain.pem -password pass:$PKCS12_PASSWORD
echo "Certificate exported to $DOMAIN.p12 with password: $PKCS12_PASSWORD"

#initialize vars
server=$1 #server parameter expected as arg
base="https://$server:8443/admin" #base expects port 8443
login="https://$server:8443/admin/login"
applianceurl="https://$server:8443/admin/appliances"
deviceid=`uuidgen | tr "[:upper:]" "[:lower:]"` #every login a random uuid will be generated
token="" #token placeholder
currentDate=`date -u +%s`
tokenDate="" #token expiration date placeholder
acceptHeader="Accept: application/vnd.appgate.peer-v19+json"
user="admin"
pass="rosebud"
cert="$1.p12"
escaped_cert=`base64 $cert`
json=""

login () {
    curl -k --location $login \
        --header 'Content-Type: application/json' \
        --header 'Accept: application/vnd.appgate.peer-v19+json' \
        --data-raw '{
            "providerName": "local",
            "deviceId": "4c07bc67-57ea-42dd-b702-c2d6c45419fc",
            "username": "admin",
            "password": "rosebud"
        }' | jq .token
    }

    token=$(login)


    token="Authorization: Bearer ${token//\"/}"
    echo $token

    get_appliances () {
        curl -k --location --request GET $applianceurl \
            --header "$acceptHeader" --header "$token" | jq .data[0]
        }

        update_appliance () {
            if [ "$1" = "data" ]; then
                echo -n \"$2\"\:\
                    jq '."'"$2"'"' data/$server.appliances
                                elif [ "$1" = "update" ]; then
                                    curl -k --location --request PUT $base/appliances/$2 \
                                        --header 'Content-Type: application/json' --header "$acceptHeader" --header "$token" --data-raw "$json"
            fi

        }

        json=$(get_appliances)

        new_httpsP12='{"httpsP12": {"id": "", "content": "'"$escaped_cert"'", "password": "rosebud"}}'

        json=$(echo "$json" | jq '.adminInterface += '"$new_httpsP12"'')

        applianceid=$(echo "$json" | jq -r '.id')

        echo $applianceid

        update_appliance "update" $applianceId
