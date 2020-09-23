#!/bin/bash

mkdir -p /pxe/dnsmasq
FILE=/pxe/ipxe/boot.ipxe
if test -f "$FILE"; then
    echo "$FILE exists."
else
    # create etc/dnsmasq.conf and set DHCP_RANGE 
    sed 's|{{ DHCP_RANGE }}|'$DHCP_RANGE'|g' /templates/dnsmasq.conf > /pxe/dnsmasq/dnsmasq.conf
    # replace PXE_IP_ADDRESS
    sed -i 's|{{ PXE_IP_ADDRESS }}|'$PXE_IP_ADDRESS'|g' /pxe/dnsmasq/dnsmasq.conf
fi

# start nginx (background)
nginx
echo "nginx Started"
# --no0daemon zodat deze zichtbaar blijft draaien
dnsmasq --no-daemon --conf-file=/pxe/dnsmasq/dnsmasq.conf
