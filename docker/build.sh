#!/bin/bash

# copy files from compiled code
cp ../compiled/ipxe/src/bin/undionly.kpxe files/ipxe
cp ../compiled/ipxe/src/bin-x86_64-efi/ipxe.efi files/ipxe
wget -N https://git.ipxe.org/releases/wimboot/wimboot-latest.zip -P ../download
unzip -o ../download/wimboot-latest.zip -d files
docker build -t opvolger/pxe:latest .