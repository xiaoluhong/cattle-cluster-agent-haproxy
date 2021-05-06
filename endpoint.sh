#!/bin/bash

set -o errexit
set -o nounset

cat /etc/kubernetes/ssl/kube-node.pem /etc/kubernetes/ssl/kube-node-key.pem > /home/ssl-crt.pem

export RISETIME=${RISETIME-60}
export CONFDAGE=${CONFDAGE-'-log-level=debug -onetime -backend env'}

export RSYSLOG_PID="/var/run/rsyslogd.pid"
rm -f $RSYSLOG_PID

echo 'info: run crond'
crond -s /var/spool/cron/crontabs -b -L /var/log/cron/cron.log

echo 'info: run rsyslogd'
rsyslogd

echo 'info: run keepalived'
/usr/local/sbin/keepalived --dont-fork --log-console -f /usr/local/etc/keepalived/keepalived.conf

echo 'info: run clusterGetnodeip'
clusterGetnodeip -rise=${RISETIME} -confd-arg="${CONFDAGE}"
