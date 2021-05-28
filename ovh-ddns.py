import json
import ovh
from requests import get

data_file_path = "/usr/local/sbin/ovh-ddns.json"


## Updates the OVH DNS record value to be the new public IP address of the server
def update_ovh(data):
    try:
        client = ovh.Client(
            endpoint            = data["ovh_endpoint"],
            application_key     = data["ovh_application_key"],
            application_secret  = data["ovh_application_secret"],
            consumer_key        = data["ovh_consumer_key"]
        )

        client.put(
            "/domain/zone/{}/record/{}".format(
                data["dns_zone_name"],
                data["dns_record_id"]
            ),
            subDomain   = data["dns_record_subdomain"],
            target      = data["dns_record_target"],
            ttl         = data["dns_record_ttl"]
        )
    except Exception as e:
        print("Unable to update OVH DNS record")
        print("Try running setup.sh again")
        print(e)
        return
    
    update_local_data_store(data)


## Updates the local ovh-ddns.json file to contain the new public IP address
def update_local_data_store(data):
    try:
        file = open(data_file_path, "w")
    except:
        print("Unable to locate ovh-ddns.json")
    else:
        data["first_time"] = False

        try:
            file.write(json.dumps(data))
            file.close()
            print("Updated old IP")
        except Exception as e:
            print(e)


## Reads ovh-ddns.json file and gets current public IP
## address and compares the two to check for a change
def main():
    old_ip = ""

    try:
        file = open(data_file_path, "r")
        data = json.loads(file.read())
        file.close()
        old_ip = data["ip"]
    except FileNotFoundError:
        print("Data file not found. Run the setup.sh script first.")
    else:
        if old_ip != "":
            try:
                current_ip = get("https://api.ipify.org").text

                if current_ip != old_ip:
                    print("IP change detected")
                    data["ip"] = current_ip
                    update_ovh(data)
                elif data["first_time"]:
                    print("First time run")
                    update_ovh(data)
                else:
                    print("No IP change detected")

            except:
                print("Unable to retrieve public IP address")


if __name__ == "__main__":
    main()
