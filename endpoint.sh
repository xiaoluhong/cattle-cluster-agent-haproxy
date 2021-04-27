#!/bin/sh

export RISETIME=60
export CONFDAGE='-log-level=debug -onetime -backend env'

haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -D -sf

cat /etc/kubernetes/ssl/kube-node.pem /etc/kubernetes/ssl/kube-node-key.pem > /home/ssl-crt.pem

clusterGetnodeip -rise=${RISETIME} -confd-arg="${CONFDAGE}"