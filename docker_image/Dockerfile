FROM centos:8 as compile_ipxe

# dependencies
RUN yum update -y
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y xz-devel

# clean old code
RUN mkdir /ipxe

# checkout code
ARG GIT_HASH
RUN git clone https://github.com/ipxe/ipxe.git /ipxe
RUN cd /ipxe && git reset --hard $GIT_HASH

# add features
# https://ipxe.org/buildcfg/console_cmd
RUN sed -i -E "s/(^\/\/#define.IMAGE_PNG)(.*)/#define IMAGE_PNG\2/" /ipxe/src/config/general.h
RUN sed -i -E "s/(^\/\/#define.CONSOLE_CMD)(.*)/#define CONSOLE_CMD\2/" /ipxe/src/config/general.h
RUN sed -i -E "s/(^\/\/#define.CONSOLE_FRAMEBUFFER)(.*)/#define CONSOLE_FRAMEBUFFER\2/" /ipxe/src/config/console.h

# check
RUN cat /ipxe/src/config/general.h | grep IMAGE_PNG
RUN cat /ipxe/src/config/general.h | grep CONSOLE_CMD
RUN cat /ipxe/src/config/console.h | grep CONSOLE_FRAMEBUFFER

# build
RUN cd /ipxe/src && make bin/undionly.kpxe
RUN cd /ipxe/src && make bin-x86_64-efi/ipxe.efi

FROM centos:8 as download_wimboot

RUN yum update -y && yum install -y wget unzip && yum clean all;

ARG WIMBOOT_VERSION
# Get version $WIMBOOT_VERSION from wimboot
# https://git.ipxe.org/release/wimboot/
RUN wget -N https://git.ipxe.org/release/wimboot/wimboot-$WIMBOOT_VERSION.zip -P /
RUN unzip -o /wimboot-$WIMBOOT_VERSION.zip -d /

FROM centos:8 as image_ipxe

ARG WIMBOOT_VERSION
# create dirs
RUN mkdir -p /files/ipxe /pxe/ipxe /templates /run/php-fpm

# copy compiled code from compile_ipxe
COPY --from=compile_ipxe /ipxe/src/bin/undionly.kpxe /files/ipxe
COPY --from=compile_ipxe /ipxe/src/bin-x86_64-efi/ipxe.efi /files/ipxe
# copy wimboot from download_wimboot
COPY --from=download_wimboot /wimboot-$WIMBOOT_VERSION/wimboot /files/ipxe

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

# template dnsmasq only proxy dhcp (for pxe-request only)
ADD templates/dnsmasq.conf /templates

# start file for transform dnsmasq.conf
ADD files/start.sh /

RUN chmod +x /start.sh

# volume for all the files
VOLUME /pxe

CMD ["./start.sh"]
