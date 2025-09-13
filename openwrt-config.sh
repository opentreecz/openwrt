#!/bin/bash

###

file_date()
{
    date --utc +%Y-%m-%d_%H%M%SZ
}
export file_date
backupfile="/root/openwrt_config_backup"

uci export > ${backupfile}-$(file_date)-pre.uci

###

mkdir /root/.ssh
chmod 700 /root/.ssh
cat << 'EOF' > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz+OMjbvbXo/fScSPaz8QBuHCXhRZcBkOLdgacwgrtA7/QbtoqxE8WIvP9shacq5nVbECdoc1Dg+ve0hH8kyYYBeFSMR6tD1TAFDV8UTxbMML7bDtwu/DNl8tCqO2Yrn+2ZqJOCq21HhGNhVjctN1hErXa6gsoAZT1zf66LyTvGzrv17squpiP/3FVrKjnk/clu2ZhNAA3V7hG2J3+Jpr6c/MabyhcNTIxTT8CdKQ2FN1eCX690TB/Sg/13qP+h1ZuPksXVbPGPEuBf6r5dKQX2ccZnk3q9y9tsdC7W1ILzc24fZqFzC+lXZVZibxVQlOEtpJYttpmj/czSTX3VcrT 
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDaQSAVHNTFpY4cxS08nVN499QHScpuEwfUnTfJXPG9x 
EOF
chmod 600 /root/.ssh/authorized_keys


opkg update
opkg download libustream-openssl
rmpkg=$(opkg install ${PWD}/$(ls libustream-openssl*)  2>&1 > /dev/null | grep already | cut -f 2 -d '*')
opkg remove luci-ssl
opkg remove $rmpkg
opkg install --cache ${PWD} libustream-openssl
opkg install luci-ssl-openssl
opkg install luci-mod-admin-full
opkg install git git-http wget curl vim-fuller htop mc iptraf-ng bash
sed -i '1croot:x:0:0:root:/root:/bin/bash' /etc/passwd
git clone https://github.com/tavinus/opkg-upgrade.git
bash /root/opkg-upgrade/opkg-upgrade.sh -f


opkg install luci-ssl-openssl luci-proto-ipv6 luci-mod-system  luci-mod-status luci-mod-network luci-mod-dsl luci-mod-admin-full

# Install all RTL and ATH9 drivers
for i in $(opkg list | grep 'rtl\|ath9' | grep -v 'rtl_433\|rtl-sdr' | cut -f 1 -d ' '); do echo $i ; opkg install $i; done

opkg install bmon iptraf-ng mc tmux git  kmod-usb-net-cdc-ether kmod-usb-net usb-modeswitch usbutils
opkg install kmod-usb-net-huawei-cdc-ncm mwan3 luci-app-mwan3 ath9k-htc-firmware
opkg install openvpn-openssl openvpn-easy-rsa luci-app-openvpn
opkg install luci-app-upnp luci-app-statistics luci-app-mwan3 luci-app-irqbalance luci-app-filemanager luci-app-filebrowser luci-app-commands 
#luci-app-ddns luci-app-cloudflared luci-app-https-dns-proxy 
rm -v ${PWD}/*.ipk

opkg remove dnsmasq
opkg install dnsmasq-full
opkg remove wpad-basic-mbedtls
opkg install wpad-openssl
# install hostapd was bad deccision
#opkg install hostapd-openssl wpa-supplicant-openssl

opkg install luci-proto-wireguard luci-proto-vxlan luci-proto-modemmanager luci-proto-ipv6
opkg install luci-app-lxc

opkg install luci-app-sshtunnel
opkg install luci-app-email

opkg install dockerd
opkg install docker
opkg install luci-app-dockerman docker-compose 
opkg install nmap-full

#remove dropbear ssh and replace with openssh
opkg remove dropbear
opkg install openssh-client openssh-client-utils openssh-keygen openssh-moduli openssh-server openssh-sftp-client openssh-sftp-server sshtunnel 

opkg install zram-swap

sync
sleep 5
uci export > ${backupfile}-$(file_date)-post.uci
sync