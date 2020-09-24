# iPXE

Ideeen opgedaan met:
- https://hub.docker.com/r/dreamcat4/pxe
- https://github.com/dreamcat4/docker-images/blob/master/pxe/Dockerfile
- https://centos.pkgs.org/8/centos-appstream-aarch64/ipxe-bootimgs-20181214-5.git133f4c47.el8.noarch.rpm.html
- https://github.com/dreamcat4/docker-images/blob/master/nginx/Dockerfile
- https://blog.n0dy.radio/2014/09/14/network-booting-with-dnsmasq-in-proxy-mode/
- https://stackoverflow.com/questions/37419042/container-command-start-sh-not-found-or-does-not-exist-entrypoint-to-contain
- https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/
- https://zhu45.org/posts/2016/Dec/21/environment-variable-substitution-using-sed/
- https://nl.wikipedia.org/wiki/TCP-_en_UDP-poorten#Vaak_gebruikte_poorten
- https://centos.pkgs.org/7/centos-aarch64/ipxe-bootimgs-20180825-2.git133f4c.el7.noarch.rpm.html
- https://docs.openstack.org/ironic/latest/install/configure-pxe.html
- https://serverfault.com/questions/829068/trouble-with-dnsmasq-dhcp-proxy-pxe-for-uefi-clients
- https://github.com/bradgillap/IPXEBOOT/blob/master/boot.ipxe
- https://ipxe.org/buildcfg/console_cmd (met console)
- https://ipxe.org/download (compile)
- https://github.com/ipxe/ipxe/releases <- 1.20.1 = 8f1514a
- https://github.com/bradgillap/IPXEBOOT
- https://ropenscilabs.github.io/r-docker-tutorial/04-Dockerhub.html

## Build

```bash
docker build -t opvolger/pxe .
```

run playbook

ansible-playbook playbook_all_steps.yaml -i inventory.yaml --vault-id thuis@~/vault-thuis.txt

ansible-playbook playbook_update_docker_files.yaml -i inventories/default.yaml  -i inventories/thuis --vault-id thuis@~/vault-thuis.txt
ansible-playbook playbook_deploy.yaml -i inventories/default.yaml  -i inventories/thuis --vault-id thuis@~/vault-thuis.txt




ipxe

```bash
git clone git://git.ipxe.org/ipxe.git
cd ipxe/src
make
make bin/undionly.kpxe
make bin-x86_64-efi/ipxe.efi
```

docker push

```bash
docker login --username opvolger --password *************
docker push opvolger/pxe
```

## TODO

- NFS server in docker
- SAMBA share in docker
- Testen
- ipxe aan de hand van mac/machinenaam: https://www.redpill-linpro.com/sysadvent/2017/12/13/ipxe-provisioning.html
- Controleren of ik alles heb.
- VMware: https://ipxe.org/howto/vmware
- uitpakken iso op samba / nfs share of dus meenemen naar docker-deploy als hij naar http moet.

