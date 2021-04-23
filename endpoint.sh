#!/bin/sh

cat /etc/kubernetes/ssl/kube-node.pem /etc/kubernetes/ssl/kube-node-key.pem > /home/ssl-crt.pem

export ENDPOINTS=$( kubectl get node -l node-role.kubernetes.io/controlplane=true --no-headers -owide | awk '{print $6}' | awk '{{printf"%s,",$0}}' | sed s'/.$//' )

touch "/usr/local/etc/haproxy/haproxy.cfg"

confd -log-level=debug -onetime -backend env

haproxy -f /usr/local/etc/haproxy/haproxy.cfg


