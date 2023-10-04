#!/usr/bin/env bash
set -Eeuo pipefail

# Docker environment variables

: ${BOOT:=''}           # URL of the ISO file
: ${DEBUG:='Y'}         # Enable debug mode
: ${ALLOCATE:='N'}      # Preallocate diskspace
: ${ARGUMENTS:=''}      # Extra QEMU parameters
: ${CPU_CORES:='1'}     # Amount of CPU cores
: ${DISK_SIZE:='32G'}   # Initial data disk size
: ${RAM_SIZE:='4G'}   # Maximum RAM amount

echo "❯ Starting QEMU for Docker v${VERSION}..."

info () { echo -e "\E[1;34m❯ \E[1;36m$1\E[0m" ; }
error () { echo -e >&2 "\E[1;31m❯ ERROR: $1\E[0m" ; }
trap 'error "Status $? while: ${BASH_COMMAND} (line $LINENO/$BASH_LINENO)"' ERR

[ ! -f "/run/run.sh" ] && error "Script must run inside Docker container!" && exit 11
[ "$(id -u)" -ne "0" ] && error "Script must be executed with root privileges." && exit 12

STORAGE="/storage"
KERNEL=$(uname -r | cut -b 1)
MINOR=$(uname -r | cut -d '.' -f2)
ARCH=amd64
VERS=$(/usr/libexec/qemu-kvm --version | head -n 1 | cut -d '(' -f 1)

[ ! -d "$STORAGE" ] && error "Storage folder (${STORAGE}) not found!" && exit 13

if [ ! -f "$STORAGE/boot.img" ]; then
  . /run/install.sh
fi

# Initialize disks
. /run/disk.sh

# Initialize network
. /run/network.sh

KVM_ERR=""
KVM_OPTS=""

if [ -e /dev/kvm ] && sh -c 'echo -n > /dev/kvm' &> /dev/null; then
  if ! grep -q -e vmx -e svm /proc/cpuinfo; then
    KVM_ERR="(vmx/svm disabled)"
  fi
else
  [ -e /dev/kvm ] && KVM_ERR="(no write access)" || KVM_ERR="(device file missing)"
fi

if [ -n "${KVM_ERR}" ]; then
  if [ "$ARCH" == "amd64" ]; then
    error "KVM acceleration not detected ${KVM_ERR}, see the FAQ about this."
    [[ "${DEBUG}" != [Yy1]* ]] && exit 88
  fi
else
  KVM_OPTS=",accel=kvm -enable-kvm -cpu host"
fi

DEF_OPTS="-nographic -nodefaults -display none"
RAM_OPTS=$(echo "-m ${RAM_SIZE}" | sed 's/MB/M/g;s/GB/G/g;s/TB/T/g')
CPU_OPTS="-smp ${CPU_CORES},sockets=1,dies=1,cores=${CPU_CORES},threads=1"
MAC_OPTS="-machine type=q35,usb=off,dump-guest-core=off,hpet=off${KVM_OPTS}"
SERIAL_OPTS="-serial mon:stdio -device virtio-serial-pci,id=virtio-serial0,bus=pcie.0,addr=0x3"
EXTRA_OPTS="-device virtio-balloon-pci,id=balloon0 -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0"

ARGS="${DEF_OPTS} ${CPU_OPTS} ${RAM_OPTS} ${MAC_OPTS} ${SERIAL_OPTS} ${NET_OPTS} ${DISK_OPTS} ${EXTRA_OPTS} ${ARGUMENTS}"
ARGS=$(echo "$ARGS" | sed 's/\t/ /g' | tr -s ' ')

trap - ERR

[[ "${DEBUG}" == [Yy1]* ]] && info "$VERS" && set -x
#exec /usr/libexec/qemu-kvm -enable-kvm -m 4G -smp 2 -hda /home/user/vm/QNX70_i440FX_Test-1.qcow2 -netdev tap,ifname=mytap00,id=net0,script=no -device e1000,netdev=net0 -device vfio-pci,host=18:00.0 -serial mon:stdio 
exec /usr/libexec/qemu-kvm -enable-kvm -m 4G -smp 2 -hda /home/user/vm/QNX70_i440FX_Test-1.qcow2 -netdev tap,ifname=mytap00,id=net0,script=no -device e1000,netdev=net0 -device virtio-net-pci,addr=18:00.0 -serial mon:stdio 
#exec /usr/libexec/qemu-kvm -enable-kvm -m 4G -smp 2 -hda /home/user/vm/QNX70_i440FX_Test-1.qcow2 -netdev tap,ifname=mytap00,id=net0,script=no -device e1000,netdev=net0 -netdev tap,ifname=mytap10,id=net1,script=no -device e1000,netdev=net1 -serial mon:stdio 


-net nic,model=virtio,macaddr=$(cat /sys/class/net/macvtap0/address) -net tap,fd=3 3<>/dev/tap$(cat /sys/class/net/macvtap0/ifindex),script=no,downscript=no


#exec /usr/libexec/qemu-kvm -enable-kvm -m 4G -smp 2 -hda /home/vm/QNX70_i440FX_Test-1.qcow2 -netdev tap,id=net0,ifname=eth0,script=no -device e1000,netdev=net0  -serial mon:stdio 

#exec qemu-system-x86_64 ${ARGS:+ $ARGS}
{ set +x; } 2>/dev/null
