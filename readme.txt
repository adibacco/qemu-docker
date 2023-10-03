 docker build -f Dockerfile -t qemu-qnx-docker-rocky .
 docker run -it --rm --device=/dev/kvm --name qemu-qnx --network host --cap-add NET_ADMIN --privileged -v /home/user/vm:/home/user/vm  qemu-qnx-docker-rocky


