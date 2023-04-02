#!/usr/bin/env bash
set -eu

[ ! -e /dev/net/tun ] && echo "Error: TUN interface not available..." && exit 85

# A bridge of this name will be created to host the TAP interface created for
# the VM
QEMU_BRIDGE='qemubr0'

# DHCPD must have an IP address to run, but that address doesn't have to
# be valid. This is the dummy address dhcpd is configured to use.
DUMMY_DHCPD_IP='10.0.0.1'

# The name of the dhcpd config file we make
DHCPD_CONF_FILE='dhcpd.conf'

function default_intf() {
    ip -json route show |
        jq -r '.[] | select(.dst == "default") | .dev'
}

# First step, we run the things that need to happen before we start mucking
# with the interfaces. We start by generating the DHCPD config file based
# on our current address/routes. We "steal" the container's IP, and lease
# it to the VM once it starts up.
/run/generate-dhcpd-conf $QEMU_BRIDGE > $DHCPD_CONF_FILE
default_dev=$(default_intf)

# Now we start modifying the networking configuration. First we clear out
# the IP address of the default device (will also have the side-effect of
# removing the default route)
ip addr flush dev "$default_dev"

# Next, we create our bridge, and add our container interface to it.
ip link add "$QEMU_BRIDGE" type bridge
ip link set dev "$default_dev" master "$QEMU_BRIDGE"

# Then, we toggle the interface and the bridge to make sure everything is up
# and running.
ip link set dev "$default_dev" up
ip link set dev "$QEMU_BRIDGE" up

# Prevent error about missing file
touch /var/lib/misc/udhcpd.leases

# Finally, start our DHCPD server
udhcpd -I $DUMMY_DHCPD_IP -f $DHCPD_CONF_FILE 2>&1 &

exit 0
