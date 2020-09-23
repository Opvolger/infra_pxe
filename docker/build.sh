#!/bin/bash

# copy files from compiled code
cp ../compiled/ipxe/src/bin/undionly.kpxe files/ipxe
cp ../compiled/ipxe/src/bin-x86_64-efi/ipxe.efi files/ipxe
docker build -t opvolger/pxe:latest .