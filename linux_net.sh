# sudo dpdk-devbind.py --bind=vfio-pci 0000:18:00.0

sudo ip link add mybr0 type bridge
sudo ip link set mybr0 up


sudo ip tuntap add mytap00 mode tap user user 
sudo ip tuntap add mytap01 mode tap user user 
sudo ip link set mytap00 up
sudo ip link set mytap01 up

sudo brctl addif mybr0 mytap00
sudo brctl addif mybr0 mytap01

sudo ip link add mybr1 type bridge
sudo ip link set mybr1 up

sudo ip tuntap add mytap10 mode tap user user 
sudo ip tuntap add mytap11 mode tap user user 
sudo ip link set mytap10 up
sudo ip link set mytap11 up


sudo brctl addif mybr1 mytap10
sudo brctl addif mybr1 mytap11

sudo ip link add link ens1f0 name macvtap0 type macvtap mode bridge
sudo ip link set dev macvtap0 up


