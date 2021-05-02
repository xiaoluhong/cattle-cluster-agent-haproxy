#!/bin/bash

set -o errexit
set -o nounset

export RSYSLOG_PID="/var/run/rsyslogd.pid"
rm -f $RSYSLOG_PID
rsyslogd

export RISETIME=${RISETIME-60}
export CONFDAGE=${CONFDAGE-'-log-level=debug -onetime -backend env'}

haproxy -f /usr/local/etc/haproxy/haproxy.cfg -p /run/haproxy.pid -D -sf

cat /etc/kubernetes/ssl/kube-node.pem /etc/kubernetes/ssl/kube-node-key.pem > /home/ssl-crt.pem

clusterGetnodeip -rise=${RISETIME} -confd-arg="${CONFDAGE}"

# logrotate /etc/logrotate.d/logrotate-haproxy.cfg