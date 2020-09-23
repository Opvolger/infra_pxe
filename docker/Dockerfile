FROM centos:8

RUN yum -y check-update || { rc=$?; [ "$rc" -eq 100 ] && exit 0; exit "$rc"; }

RUN yum update -y

# install dnsmasq
RUN yum -y install dnsmasq

# install nginx
RUN yum -y install nginx

# install nano wget unzip
RUN yum -y install nano wget unzip

# install ipxe
RUN yum -y install ipxe-bootimgs

# cleanup yum 
RUN yum clean all;

# default env
ENV DHCP_RANGE=192.168.2.150
ENV PXE_IP_ADDRESS=192.168.2.17

# http
EXPOSE 80
# DHCP
EXPOSE 67 67/udp 69 69/udp

RUN mkdir /pxe
RUN mkdir /templates

# Change html folder from /www to /pxe
RUN sed -i -e 's|/usr/share/nginx/html;|/pxe;|' /etc/nginx/nginx.conf
# Enable autoindex (file browsing)
RUN sed -i -e 's|location / {|location / { autoindex on;|' /etc/nginx/nginx.conf

RUN wget -O /tmp/wimboot.zip https://git.ipxe.org/releases/wimboot/wimboot-latest.zip \
 && unzip -j /tmp/wimboot.zip */wimboot -d /pxe/ipxe && $_clean

ADD files/start.sh /

ADD templates/boot.ipxe /templates
ADD templates/dnsmasq.conf /templates

RUN chmod +x /start.sh

# alles van nginx in de logging
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

# alles van dnsmasq.log
# hoeft niet, de draaien dnsmasq in --no-deamon
#RUN ln -sf /dev/stdout /tmp/dnsmasq.log

VOLUME /pxe

CMD ["./start.sh", "twee"]