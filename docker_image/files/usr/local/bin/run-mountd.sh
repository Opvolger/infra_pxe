set -eu

exportfs -ar
rpcbind
rpc.statd
rpc.nfsd

exec rpc.mountd --foreground