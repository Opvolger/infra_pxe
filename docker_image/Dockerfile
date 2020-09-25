FROM centos:8

RUN yum -y check-update || { rc=$?; [ "$rc" -eq 100 ] && exit 0; exit "$rc"; }

RUN yum update -y && yum install -y dnsmasq nginx php-fpm php-common php-cli && yum clean all;

# default env
ENV DHCP_RANGE=192.168.2.150
ENV PXE_IP_ADDRESS=192.168.2.17

# HTTP / DHCP / TFTP
EXPOSE 80 67 67/udp 69 69/udp

# Change html folder from /www to /pxe
# && Enable autoindex (file browsing)
RUN sed -i -e 's|/usr/share/nginx/html;|/pxe;|' /etc/nginx/nginx.conf \
    && sed -i -e 's|location / {|location / { autoindex on;|' /etc/nginx/nginx.conf

# nginx logging to stdout en stderr (logging docker)
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

# create dirs
RUN mkdir -p /files/ipxe /pxe/ipxe /templates /run/php-fpm

# ipxe files (boot files)
# todo version in dir
ADD files/wimboot-2.6.0-signed/wimboot /files/ipxe
ADD files/ipxe/undionly.kpxe /files/ipxe
ADD files/ipxe/ipxe.efi /files/ipxe

# template dnsmasq only proxy dhcp (for pxe-request only)
ADD templates/dnsmasq.conf /templates

# start file for transform dnsmasq.conf
ADD files/start.sh /

RUN chmod +x /start.sh

# volume for all the files
VOLUME /pxe

CMD ["./start.sh"]
