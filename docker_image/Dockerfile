FROM centos:8 as compile_ipxe

# dependencies
RUN yum update -y && yum groupinstall -y 'Development Tools' && yum install -y xz-devel && yum clean all;

# checkout code
ARG GIT_HASH
RUN mkdir /ipxe && git clone https://github.com/ipxe/ipxe.git /ipxe && cd /ipxe && git reset --hard $GIT_HASH

# add features
# https://ipxe.org/buildcfg/console_cmd
RUN sed -i -E "s/(^\/\/#define.IMAGE_PNG)(.*)/#define IMAGE_PNG\2/" /ipxe/src/config/general.h \
 && sed -i -E "s/(^\/\/#define.CONSOLE_CMD)(.*)/#define CONSOLE_CMD\2/" /ipxe/src/config/general.h \
 && sed -i -E "s/(^\/\/#define.CONSOLE_FRAMEBUFFER)(.*)/#define CONSOLE_FRAMEBUFFER\2/" /ipxe/src/config/console.h

# compile source
RUN cd /ipxe/src && make bin/undionly.kpxe && cd /ipxe/src && make bin-x86_64-efi/ipxe.efi

FROM centos:8 as download_wimboot

# dependencies
RUN yum update -y && yum install -y wget unzip && yum clean all;

# version wimboot
ARG WIMBOOT_VERSION
# https://git.ipxe.org/release/wimboot/
RUN wget -N https://git.ipxe.org/release/wimboot/wimboot-$WIMBOOT_VERSION-signed.zip -P / &&  unzip -o /wimboot-$WIMBOOT_VERSION-signed.zip -d /

FROM centos:8 as image_ipxe

ARG WIMBOOT_VERSION

# create dirs
RUN mkdir -p /files/ipxe /pxe/ipxe /templates /run/php-fpm /var/log/supervisor

# copy compiled code from compile_ipxe
COPY --from=compile_ipxe /ipxe/src/bin/undionly.kpxe /files/ipxe
COPY --from=compile_ipxe /ipxe/src/bin-x86_64-efi/ipxe.efi /files/ipxe
# copy wimboot from download_wimboot
COPY --from=download_wimboot /wimboot-$WIMBOOT_VERSION-signed/wimboot /files/ipxe

# you need epel-release for supervisor
RUN yum install epel-release -y
RUN yum -y check-update || { rc=$?; [ "$rc" -eq 100 ] && exit 0; exit "$rc"; }
RUN yum update -y && yum install -y nfs-utils samba samba-common dnsmasq supervisor nginx php-fpm php-common php-cli && yum clean all;

# default env
ENV container=docker
# dhcp proxy mode. do not act as the authoratitive dhcp server
ENV DHCP_RANGE=192.168.2.0,proxy
# my pxe server at home
ENV PXE_IP_ADDRESS=192.168.2.17

# HTTP / DHCP / TFTP
EXPOSE 80 67 67/udp 69 69/udp 139 445 111/udp 2049/tcp

# Change html folder from /www to /pxe
# && Enable autoindex (file browsing)
# && logging to docker logs (/dev/stdout /dev/stderr)
RUN sed -i -e 's|/usr/share/nginx/html;|/pxe;|' /etc/nginx/nginx.conf \
    && sed -i -e 's|location / {|location / { autoindex on;|' /etc/nginx/nginx.conf \
    && sed -i -e 's|/var/log/nginx/error.log|/dev/stderr|' /etc/nginx/nginx.conf \
    && sed -i -e 's|/var/log/nginx/access.log|/dev/stdout|' /etc/nginx/nginx.conf

# template dnsmasq only proxy dhcp (for pxe-request only)
ADD templates/dnsmasq.conf /templates

# docker-entrypoint file for transform dnsmasq.conf
COPY files /

RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /usr/local/bin/run-mountd.sh

# volume for all the files
VOLUME /pxe

CMD ["./docker-entrypoint.sh"]
