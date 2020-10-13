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

_sysconfig_nfs() {
  cat > /etc/sysconfig/nfs <<EOF
#
#
# To set lockd kernel module parameters please see
#  /etc/modprobe.d/lockd.conf
#
# Optional arguments passed to rpc.nfsd. See rpc.nfsd(8)
RPCNFSDARGS=""
# Number of nfs server processes to be started.
# The default is 8.
RPCNFSDCOUNT=8
#
# Set V4 grace period in seconds
#NFSD_V4_GRACE=90
#
# Set V4 lease period in seconds
#NFSD_V4_LEASE=90
#
# Optional arguments passed to rpc.mountd. See rpc.mountd(8)
RPCMOUNTDOPTS=""
# Port rpc.mountd should listen on.
#MOUNTD_PORT=892
#
# Optional arguments passed to rpc.statd. See rpc.statd(8)
STATDARG=""
# Port rpc.statd should listen on.
#STATD_PORT=662
# Outgoing port statd should used. The default is port
# is random
#STATD_OUTGOING_PORT=2020
# Specify callout program
#STATD_HA_CALLOUT="/usr/local/bin/foo"
#
#
# Optional arguments passed to sm-notify. See sm-notify(8)
SMNOTIFYARGS=""
#
# Optional arguments passed to rpc.idmapd. See rpc.idmapd(8)
RPCIDMAPDARGS=""
#
# Optional arguments passed to rpc.gssd. See rpc.gssd(8)
# Note: The rpc-gssd service will not start unless the
#       file /etc/krb5.keytab exists. If an alternate
#       keytab is needed, that separate keytab file
#       location may be defined in the rpc-gssd.service's
#       systemd unit file under the ConditionPathExists
#       parameter
RPCGSSDARGS=""
#
# Enable usage of gssproxy. See gssproxy-mech(8).
GSS_USE_PROXY="yes"
#
# Optional arguments passed to blkmapd. See blkmapd(8)
BLKMAPDARGS=""
EOF
}

echo Create config nfs
_sysconfig_nfs

# create sock for php
echo Create sock for php
touch /run/php-fpm/www.sock

echo Start the supervisord
supervisord -c /etc/supervisord.conf
