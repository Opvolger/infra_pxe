#!/bin/bash

# copy boot files
mkdir -p /pxe/ipxe
cp /usr/share/ipxe/* /pxe/ipxe/

FILE=/pxe/ipxe/boot.ipxe
if test -f "$FILE"; then
    echo "$FILE exists."
else
    echo "$FILE does not exist."
    sed 's|{{ SAMBA_IP_ADDRESS }}|'$SAMBA_IP_ADDRESS'|g' /templates/boot.ipxe > /pxe/ipxe/boot.ipxe
    sed -i 's|{{ SAMBA_SHARE }}|'$SAMBA_SHARE'|g' /pxe/ipxe/boot.ipxe
    sed -i 's|{{ SAMBA_USERNAME }}|'$SAMBA_USERNAME'|g' /pxe/ipxe/boot.ipxe
    sed -i 's|{{ SAMBA_PASSWORD }}|'$SAMBA_PASSWORD'|g' /pxe/ipxe/boot.ipxe
fi

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
