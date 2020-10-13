#!/bin/bash

# copy ipxe and wimboot files to volume
echo Copy ipxe and wimboot
cp /files/ipxe/* /pxe/ipxe

# create dnsmasq files (if nog exists)
mkdir -p /pxe/dnsmasq
FILE=/pxe/dnsmasq/dnsmasq.conf
if test -f "$FILE"; then
    echo "$FILE exists."
else
    echo create dnsmasq.conf
    # create etc/dnsmasq.conf and set DHCP_RANGE 
    sed 's|{{ DHCP_RANGE }}|'$DHCP_RANGE'|g' /templates/dnsmasq.conf > /pxe/dnsmasq/dnsmasq.conf
    # replace PXE_IP_ADDRESS
    sed -i 's|{{ PXE_IP_ADDRESS }}|'$PXE_IP_ADDRESS'|g' /pxe/dnsmasq/dnsmasq.conf
fi

# create sock for php
echo Create sock for php
touch /run/php-fpm/www.sock

echo Start the supervisord
supervisord -c /etc/supervisord.conf
