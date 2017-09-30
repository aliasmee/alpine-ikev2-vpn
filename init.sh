#!/bin/bash
set -e
# Preload iptables,Rule lost when preventing restart of container!
iptables-restore < /etc/sysconfig/iptables

exec "$@"
