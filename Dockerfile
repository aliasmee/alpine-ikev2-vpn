# From alpine:latest image
FROM alpine:latest

MAINTAINER @aliasmee

# Define a dynamic variable for Certificate CN
ENV HOST_IP ''
ENV VPNUSER ''
ENV VPNPASS ''
ENV TZ=Asia/Shanghai

# strongSwan Version
ARG SS_VERSION="https://download.strongswan.org/strongswan-5.6.2.tar.gz"

# download en
ARG BUILD_DEPS="gettext"
ARG RUNTIME_DEPS="libintl"

# Install dep packge , Configure,make and install strongSwan
RUN apk --update add build-base curl bash iproute2 iptables-dev openssl openssl-dev supervisor bash && mkdir -p /tmp/strongswan \
    && apk add --update $RUNTIME_DEPS && apk add --virtual build_deps $BUILD_DEPS && cp /usr/bin/envsubst /usr/local/bin/envsubst \
    && curl -Lo /tmp/strongswan.tar.gz $SS_VERSION && tar --strip-components=1 -C /tmp/strongswan -xf /tmp/strongswan.tar.gz \
    && cd /tmp/strongswan \
    && ./configure  --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2 --enable-eap-tls --enable-eap-ttls --enable-eap-peap --enable-eap-tnc --enable-eap-dynamic --enable-eap-radius --enable-xauth-eap  --enable-dhcp  --enable-openssl  --enable-addrblock --enable-unity --enable-certexpire --enable-radattr --enable-swanctl --enable-openssl --disable-gmp && make && make install \
    && rm -rf /tmp/* && apk del build-base curl openssl-dev build_deps && rm -rf /var/cache/apk/* \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 

# Change local zonetime(BeiJing)
# RUN \cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

# Create cert dir
RUN mkdir -p /data/key_files

# Copy configure file to ipsec\iptables
COPY ./conf/strongswan.conf /usr/local/etc/strongswan.conf 
COPY ./conf/ipsec.secrets /usr/local/etc/ipsec.secrets
COPY ./conf/iptables /etc/sysconfig/iptables
COPY ./conf/supervisord.conf /etc/supervisord.conf
COPY ./conf/eap-radius.conf.template eap-radius.conf.template
COPY ./conf/ipsec.conf.template ipsec.conf.template

# Make cert script and copy cert to ipsec dir
COPY ./scripts/vpn /usr/bin/vpn

# Open udp 500\4500 port
EXPOSE 500:500/udp 4500:4500/udp

# Privilege mode
#CMD ["/usr/bin/supervisord"]
ADD init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh","/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
