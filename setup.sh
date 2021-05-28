#!/bin/bash

## Check if running script as root or sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root or sudo"
  exit
fi


## Checking which version of Python is installed
## Will use Python3 if both are present
## Will exit if no Python versions are present
PYTHON2=false
PYTHON3=false

if ls /usr/bin/python2* 1> /dev/null 2>&1; then
  PYTHON2=true
fi

if ls /usr/bin/python3* 1> /dev/null 2>&1; then
  PYTHON3=true
fi

if [[ !($PYTHON2) && !($PYTHON3) ]]; then
  echo "Python is not installed. Exiting..."
  exit
fi

if [[ $PYTHON2 && !($PYTHON3) ]]; then
  sed -i "s/ExecStart=/usr/bin/python3 /usr/local/sbin/ovh-ddns.py/ExecStart=/usr/bin/python /usr/local/sbin/ovh-ddns.py/" ovh-ddns.service
fi


## Installs python script dependencies using pip
echo "Installing dependencies..."
if [[ $PYTHON3 ]]; then
  pip3 install ovh
else
  pip install ovh
fi


## Change file permissions
echo "Updating file permissions"
chmod 777 ovh-ddns.service
chmod 777 ovh-ddns.py
chmod 777 ovh-ddns.json


## Retrieves current public IP address, desired DNS record
## properties and OVH API credentials and saves to ovh-ddns.json
function get_int() {
  read -p "$1: " INT_INPUT
  if [[ $INT_INPUT =~ ^[0-9]+$ && "$INT_INPUT" -gt "0" ]]; then
    echo $INT_INPUT
  else
    echo $(get_int "$1")
  fi
}

CURRENT_IP=$(curl ipinfo.io/ip)
echo
read -p "DNS zone name: " DNS_ZONE_NAME
read -p "DNS record ID: " DNS_RECORD_ID
read -p "DNS record subdomain: " DNS_RECORD_SUBDOMAIN
read -p "DNS record target: " DNS_RECORD_TARGET
DNS_RECORD_TTL=$(get_int "DNS record TTL (secs)")

read -p "OVH endpoint [e.g. ovh-eu]: " OVH_ENDPOINT
read -p "OVH application key: " OVH_APPLICATION_KEY
read -p "OVH application secret: " OVH_APPLICATION_SECRET
read -p "OVH consumer key: " OVH_CONSUMER_KEY

echo "{ \"ip\": \"${CURRENT_IP}\", \"dns_zone_name\": \"$DNS_ZONE_NAME\", \"dns_record_id\": \"$DNS_RECORD_ID\", \"dns_record_subdomain\": \"$DNS_RECORD_SUBDOMAIN\", \"dns_record_target\": \"$DNS_RECORD_TARGET\", \"dns_record_ttl\": $DNS_RECORD_TTL, \"ovh_endpoint\": \"$OVH_ENDPOINT\", \"ovh_application_key\": \"$OVH_APPLICATION_KEY\", \"ovh_application_secret\": \"$OVH_APPLICATION_SECRET\", \"ovh_consumer_key\": \"$OVH_CONSUMER_KEY\", \"first_time\": true }" > ovh-ddns.json


## Retrieves desired checking interval and saves to ovh-ddns.service using unix Stream Editor (sed)
SERVICE_INTERVAL=$(get_int "Service interval (secs)")
sed -i "s/RestartSec=.*/RestartSec=$SERVICE_INTERVAL/" ovh-ddns.service


## Copies service python and json files to relevent their locations
echo "Copying files to relevent directories"
cp ./ovh-ddns.service /etc/systemd/system/ovh-ddns.service
cp ./ovh-ddns.py /usr/local/sbin/ovh-ddns.py
cp ./ovh-ddns.json /usr/local/sbin/ovh-ddns.json


## Reloads systemd manager configuration for new service
systemctl daemon-reload


## Checks if user wishes to have service launch on boot and executes relevent command
while true; do
  read -p "Auto-start on boot? (y/n): " RESPONSE
  case $RESPONSE in
    [Yy]* )
      systemctl enable ovh-ddns.service;
    break;;
    [Nn]* )
    break;;
  esac
done


## Starts the service
echo "Starting service..."
systemctl start ovh-ddns.service

echo "Successfully installed!"
echo