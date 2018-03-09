#!/usr/bin/env bash

LOCAL_HOST="/Users/dabou/images"
CENTOS_ISO="CentOS-7-x86_64-Minimal-1708.iso"
ISO_NAME="centos7.iso"
ISO="$LOCAL_HOST/$CENTOS_ISO"
virtualbox_vm_name="CentOS-7.1" # VM Name

cat > centos-7.ks << 'EOF'
# Action
install

# Run the Setup Agent on first boot
firstboot --enable

# Accept Eula
eula --agreed

# Keyboard layouts
keyboard --vckeymap=es --xlayouts='es'
# System language
lang en_US.UTF-8

# Root pwd
sshpw --username=root --plaintext centos
rootpw --plaintext centos
auth --useshadow --passalgo=sha512

# System timezone
timezone Europe/Brussels --isUtc --ntpservers=0.centos.pool.ntp.org,1.centos.pool.ntp.org,2.centos.pool.ntp.org,3.centos.pool.ntp.org

# System services
services --enabled=NetworkManager,sshd

# Reboot after installing
reboot

# Firewall configuration
firewall --enabled --ssh

# Network information
network  --bootproto=dhcp --device=eth0

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda
autopart --type=lvm
zerombr

# Partition clearing information
clearpart --all --drives=sda
ignoredisk --only-use=sda

%packages  --excludedocs --instLangs=en
@core
openssl
bash
dracut
e4fsprogs
efibootmgr
grub2
grub2-efi
kernel
net-tools
parted
shadow-utils
shim
syslinux
cifs-utils
fuse-sshfs
nfs-utils
go-hvkvp
python-setuptools
%end
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
implantisomd5 "/tmp/boot.iso"
cp /tmp/boot.iso $LOCAL_HOST/$ISO_NAME
