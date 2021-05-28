# OVH DDNS

A linux service to periodically check for public IP address changes. Updates OVH DNS record using Python and the OVH API. Pretty much a dynamic DNS solution.

## Requirements
- Linux
  - Python 2.x or Python 3.x with binary in `/usr/bin/`
  - Pip or Pip3 with binary in `/usr/bin/`
  - Sudo privileges
- OVH API Credentials
  - Application Key
  - Application Secret
  - Consumer Key
  - Generate new credentials on the [OVH token creation page](https://api.ovh.com/createToken/index.cgi?PUT=/*)

## Installation
```bash
## Clone the git repository and move into it
git clone https://github.com/HariboDev/ovh-ddns.git
cd ovh-ddns

## Change the permissions on the setup script to allow for execution
sudo chmod +x ./setup.sh

## Execute the script
## You must be sudo or root
sudo ./setup.sh
```
The `setup.sh` script:
  - Checks if currently running as sudo or root
  - Attempts to locate the Python binaries for Python2.x or Python3.x
  - Prefers Python3.x if possible
  - Installs dependencies
  - Changes the file permissions
  - Asks for the following:
    - DNS zone name
    - DNS record ID
    - Subdomain to be updated
    - Record target
    - DNS record TTL (must be int && > 0)
    - Service interval time (must be int && > 0)
  - Retrieves the current IP address of the server
  - Populates the `ovh-ddns.json` data file
  - Moves the service, Python script and data files to relevent directories
  - Reloads the system manager configuration using `systemctl daemon-reload`
  - Asks if you want to load the service on server boot:
    - If so, enables the service using `systemctl enable ovh-ddns.service`
  - Starts the service using `systemctl start ovh-ddns.service`

## Usage
When the service is running, the Python interpreter is used to:
  - Check for a change in the server's public IP
  - Attempts to update the OVH DNS record
  - Updates `ovh-dns.json` data file to hold the new public IP address

To view the logs to check for success or failures, execute the following command:
```bash
sudo journalctl -xe -u ovh-ddns.service -f
```

## Uninstallation
```bash
## Move into the directory of the repository
cd ovh-ddns

## Change the permissions on the script to allow for execution
sudo chmod +x ./uninstall.sh

## Execute the script
## You must be sudo or root
sudo ./uninstall.sh
```
The `uninstall.sh`:
  - Disables the service
  - Stops the service
  - Deletes the service files
  - Deletes the Python script and data files
