FROM rockylinux:9.1

RUN cd /etc/yum/vars && sed -i s/pub/vault/g contentdir && sed -i s/9-stream/9-1/g stream
RUN cd /etc/yum.repos.d && sed -i s/^\#baseurl/baseurl/g rocky*.repo &&  sed -i s/^mirrorlist/\#mirrorlist/g rocky*.repo && sed -i s/\$releasever/9\.1/g rocky*.repo

RUN yum install -y yum-utils 
RUN dnf config-manager --set-enabled crb && dnf -y install epel-release
RUN cd /etc/yum.repos.d && sed -i s/^\#baseurl/baseurl/g rocky*.repo &&  sed -i s/^mirrorlist/\#mirrorlist/g rocky*.repo && sed -i s/\$releasever/9\.1/g rocky*.repo

RUN dnf makecache --refresh
RUN dnf install -y wget 
RUN	dnf install -y procps 
RUN	dnf install -y iptables 
RUN	dnf install -y iptables-nft 
RUN	dnf install -y iptables-legacy
RUN	dnf install -y nftables
RUN	dnf install -y iproute
RUN	dnf install -y dnsmasq 
RUN	dnf install -y net-tools 
RUN	dnf install -y ca-certificates 
RUN	dnf install -y netcat
RUN	dnf install -y openssh-clients
RUN	dnf install -y sshpass
RUN	dnf install -y qemu-kvm

COPY run/*.sh /run/
RUN chmod +x /run/*.sh

VOLUME /storage

EXPOSE 22

ENV CPU_CORES "1"
ENV DISK_SIZE "32G"
ENV RAM_SIZE "4096M"
ENV BOOT "/home/vm/QNX70_i440FX_Test-1.qcow2"
#ENV BOOT "/home/vm/ubuntu22.04.qcow2"
#ENV BOOT "user@10.14.89.60:/home/user/vm/QNX70_i440FX_Test-1.qcow2"
#ENV BOOT "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.3-x86_64.iso"

ARG DATE_ARG=""
ARG BUILD_ARG=0
ARG VERSION_ARG="0.0"
ENV VERSION=$VERSION_ARG

LABEL org.opencontainers.image.created=${DATE_ARG}
LABEL org.opencontainers.image.revision=${BUILD_ARG}
LABEL org.opencontainers.image.version=${VERSION_ARG}
LABEL org.opencontainers.image.source=https://github.com/qemu-tools/qemu-docker/
LABEL org.opencontainers.image.url=https://hub.docker.com/r/qemux/qemu-docker/

ENTRYPOINT ["/run/run.sh"]
