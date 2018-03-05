#!/bin/bash
set -e
# Preload iptables,Rule lost when preventing restart of container!
iptables-restore < /etc/sysconfig/iptables

# Repair gcp container restart, can not access google family bucket(Disable pmtu discovery!)
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.ip_no_pmtu_disc=1

# Setting eap-radius config info
if [ -z "$ACCOUNTING" ]; then
  export ACCOUNTING=no
fi

if [ -z "$RADIUS_PORT" ]; then
  export RADIUS_PORT=1812
fi

if [ -z "$RADIUS_SERVER" ]; then
  export RADIUS_SERVER=''
fi

if [ -z "$RADIUS_SECRET" ]; then
  export RADIUS_SECRET=''
fi

envsubst '
          ${ACCOUNTING}
          ${RADIUS_PORT}
          ${RADIUS_SERVER}
          ${RADIUS_SECRET}
         ' < eap-radius.conf.template > /usr/local/etc/strongswan.d/charon/eap-radius.conf

# Setting eap auth type
if [ -z "$EAP_TYPE" ]; then
  export EAP_TYPE='eap-mschapv2'
fi

if [ -z "$HOST_IP" ]; then
  export HOST_IP='0.0.0.0'
fi

envsubst '
         ${EAP_TYPE}
         ${HOST_IP}
         ' < ipsec.conf.template > /usr/local/etc/ipsec.conf

exec "$@"
