#!/bin/bash
set -e
# Preload iptables,Rule lost when preventing restart of container!
iptables-restore < /etc/sysconfig/iptables

# Repair gcp container restart, can not access google family bucket(Disable pmtu discovery!)
sysctl -w net.ipv4.ip_no_pmtu_disc=1


exec "$@"
