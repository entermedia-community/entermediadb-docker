#!/bin/sh
#set -x

#To Connect to VPN - openconnect
#Put this script in the home directory and make it executable
#Add the path to the script to the openconnect VPN Configuration Dialog.

platform_version="x86x64"
device_type="Linux-x86"
device_uniqueid="AAAAAAA"

# delete the csdXXXXXX temp files so they don't start piling up
rm -f $1

exec curl \
--globoff \
--insecure \
--user-agent "AnyConnect Linux" \
--header "X-Transcend-Version: 1" \
--header "X-Aggregate-Auth: 1" \
--header "X-AnyConnect-Identifier-Platform: linux" \
--header "X-AnyConnect-Identifier-PlatformVersion: $platform_version" \
--header "X-AnyConnect-Identifier-DeviceType: $device_type" \
--header "X-AnyConnect-Identifier-Device-UniqueID: $uniqueid" \
--cookie "sdesktop=$CSD_TOKEN" \
--data-ascii @- "https://$CSD_HOSTNAME/+CSCOE+/sdesktop/scan.xml" <<END
endpoint.feature="failure";
endpoint.os.version="Linux";
END
