set -eu

exportfs -a
rpcbind
rpc.statd -p 662 -o 2020
rpc.nfsd

exec rpc.mountd -p 892 --foreground