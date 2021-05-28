#!/bin/bash


## Check if running script as root or sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root or sudo"
  exit
fi


## Stops, disables and deletes service
echo "Disabling service..."
systemctl disable ovh-ddns.service

echo "Stopping service..."
systemctl stop ovh-ddns.service

echo "Deleting service..."
rm /etc/systemd/system/ovh-ddns.service


## Removes scripts and data files
echo "Deleting scripts and data..."
rm /usr/local/sbin/ovh-ddns.py
rm /usr/local/sbin/ovh-ddns.json

echo "Uninstalled!"
echo