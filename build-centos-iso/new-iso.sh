#!/usr/bin/env bash

LOCAL_HOST="/Users/dabou/images"
CENTOS_ISO="CentOS-7-x86_64-Minimal-1708.iso"
ISO_NAME="centos7.iso"
ISO="$LOCAL_HOST/$CENTOS_ISO"
virtualbox_vm_name="CentOS-7.1" # VM Name

cat > centos-7.ks << 'EOF'
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Firewall configuration
firewall --enabled --ssh
# Use CDROM installation media
cdrom
# Network information
network  --bootproto=dhcp --device=eth0
EOF

echo "##### Create our own ISO ....."
rm -rf /tmp/bootiso
rm -rf /tmp/bootisoks

mkdir /tmp/bootiso
sudo mount -o loop $LOCAL_HOST/CentOS-7-x86_64-Minimal-1708.iso /tmp/bootiso
mkdir /tmp/bootisoks

cp -r /tmp/bootiso/* /tmp/bootisoks/
sudo umount /tmp/bootiso && rmdir /tmp/bootiso
chmod -R u+w /tmp/bootisoks
cp centos7-2.ks /tmp/bootisoks/isolinux/ks.cfg
sed -i 's/append\ initrd\=initrd.img$/append initrd=initrd.img\ ks\=cdrom:\/ks.cfg/' /tmp/bootisoks/isolinux/isolinux.cfg
cd /tmp/bootisoks && mkisofs -o /tmp/boot.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64" -R -J -v -T isolinux/. .
cp /tmp/boot.iso $LOCAL_HOST/$ISO_NAME