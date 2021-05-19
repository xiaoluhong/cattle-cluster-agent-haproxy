FROM    golang:1.16.3 AS builder

RUN     cd / \
    &&  git clone https://github.com/MrYuanZhen/kubernetes_tools.git \
    &&  cd /kubernetes_tools/clusterGetnodeip \
    &&  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

FROM    alpine:edge

# Get confd
ARG     CONFD_VERSION=0.16.0

RUN     apk update \
    &&  apk add \
        keepalived \
        wget \
        openssl \
        iptables \
        curl \
        bash \
        ipvsadm \
        bash-completion \
        vim \
        net-tools \
        iputils \
        rsyslog \
        ca-certificates \
        logrotate \
        rsync \
        dcron \
    &&  rm -rf /var/cache/apk/*

RUN     mkdir -p /etc/rsyslog.d/ /var/log/cron \
    &&  mkdir -m 0644 -p /var/spool/cron/crontabs /etc/cron.d \
    &&  touch /var/log/cron/cron.log /var/log/keepalived.log \
    &&  sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
    &&  sed -i '/*.info;au/s/^/#/' /etc/rsyslog.conf

# Get kubectl and confd
RUN     curl -LSs -O https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
    &&  mv ./kubectl /usr/local/bin/kubectl \
    &&  chmod +x /usr/local/bin/kubectl \
    &&  curl -LSs -o /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64

COPY    confd/ /etc/confd/
COPY    endpoint.sh /endpoint.sh
COPY    rsyslog.conf /etc/rsyslog.d/
COPY    logrotate-keepalived.cfg /etc/logrotate.d/logrotate-keepalived

# 此处添加小工具
COPY    --from=builder /kubernetes_tools/clusterGetnodeip/clusterGetnodeip /usr/bin/clusterGetnodeip

RUN     chmod +x /usr/bin/confd /endpoint.sh /usr/bin/clusterGetnodeip

WORKDIR /var/log

CMD     /endpoint.sh
