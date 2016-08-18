mkdir -p /etc/prime
install -D -m 0755 prime-offload.sh /etc/prime/
install -m 0644 xorg.conf /etc/prime/
install -D -m 0755 prime-select.sh /usr/sbin/prime-select
