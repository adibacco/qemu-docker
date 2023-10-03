sudo dpdk-devbind.py --bind=vfio-pci 0000:18:00.0

sudo ip link add Gefyra0 type bridge
sudo ip link set Gefyra0 up


sudo ip tuntap add QemuTap0 mode tap user user 
sudo ip tuntap add QemuTap1 mode tap user user 
sudo ip link set QemuTap0 up
sudo ip link set QemuTap1 up


