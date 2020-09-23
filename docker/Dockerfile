FROM centos:8

RUN yum -y check-update || { rc=$?; [ "$rc" -eq 100 ] && exit 0; exit "$rc"; }

RUN yum update -y

# install dnsmasq
RUN yum -y install dnsmasq

# install nginx
RUN yum -y install nginx

# cleanup yum 
RUN yum clean all;

# default env
ENV DHCP_RANGE=192.168.2.150
ENV PXE_IP_ADDRESS=192.168.2.17

# http
EXPOSE 80

# DHCP
EXPOSE 67 67/udp 69 69/udp

# Change html folder from /www to /pxe
RUN sed -i -e 's|/usr/share/nginx/html;|/pxe;|' /etc/nginx/nginx.conf

# Enable autoindex (file browsing)
RUN sed -i -e 's|location / {|location / { autoindex on;|' /etc/nginx/nginx.conf

# nginx logging to stdout en stderr (logging docker)
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /files/ipxe
RUN mkdir -p /pxe/ipxe
RUN mkdir /templates

# ipxe files (boot files)
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