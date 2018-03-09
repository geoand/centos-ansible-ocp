#!/usr/bin/env bash

LOCAL_HOST="/Users/dabou/images"
CENTOS_ISO="CentOS-7-x86_64-Minimal-1708.iso"
ISO_NAME="centos7.iso"
ISO="$LOCAL_HOST/$CENTOS_ISO"

cat > centos-7.ks << 'EOF'
# Action
install
cdrom

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
python-setuptools
%end
EOF

cat > isolinux.cfg << 'EOF'
default vesamenu.c32
timeout 1

display boot.msg

# Clear the screen when exiting the menu, instead of leaving the menu displayed.
# For vesamenu, this means the graphical background is still displayed without
# the menu itself for as long as the screen remains in graphics mode.
menu clear
menu background splash.png
menu title CentOS 7
menu vshift 8
menu rows 18
menu margin 8
#menu hidden
menu helpmsgrow 15
menu tabmsgrow 13

# Border Area
menu color border * #00000000 #00000000 none

# Selected item
menu color sel 0 #ffffffff #00000000 none

# Title bar
menu color title 0 #ff7ba3d0 #00000000 none

# Press [Tab] message
menu color tabmsg 0 #ff3a6496 #00000000 none

# Unselected menu item
menu color unsel 0 #84b8ffff #00000000 none

# Selected hotkey
menu color hotsel 0 #84b8ffff #00000000 none

# Unselected hotkey
menu color hotkey 0 #ffffffff #00000000 none

# Help text
menu color help 0 #ffffffff #00000000 none

# A scrollbar of some type? Not sure.
menu color scrollbar 0 #ffffffff #ff355594 none

# Timeout msg
menu color timeout 0 #ffffffff #00000000 none
menu color timeout_msg 0 #ffffffff #00000000 none

# Command prompt text
menu color cmdmark 0 #84b8ffff #00000000 none
menu color cmdline 0 #ffffffff #00000000 none

# Do not display the actual menu unless the user presses a key. All that is displayed is a timeout message.

menu tabmsg Press Tab for full configuration options on menu items.

menu separator # insert an empty line
menu separator # insert an empty line

label linux
  menu label ^Install CentOS 7
  kernel vmlinuz
  append initrd=initrd.img ks=cdrom:/ks.cfg inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet

label check
  menu label Test this ^media & install CentOS 7
  menu default
  kernel vmlinuz
  append initrd=initrd.img ks=cdrom:/ks.cfg inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet

menu separator # insert an empty line

# utilities submenu
menu begin ^Troubleshooting
  menu title Troubleshooting

label vesa
  menu indent count 5
  menu label Install CentOS 7 in ^basic graphics mode
  text help
        Try this option out if you're having trouble installing
        CentOS 7.
  endtext
  kernel vmlinuz
  append initrd=initrd.img ks=cdrom:/ks.cfg inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet

label rescue
  menu indent count 5
  menu label ^Rescue a CentOS system
  text help
        If the system will not boot, this lets you access files
        and edit config files to try to get it booting again.
  endtext
  kernel vmlinuz
  append initrd=initrd.img ks=cdrom:/ks.cfg inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rescue quiet

label memtest
  menu label Run a ^memory test
  text help
        If your system is having issues, a problem with your
        system's memory may be the cause. Use this utility to
        see if the memory is working correctly.
  endtext
  kernel memtest

menu separator # insert an empty line

label local
  menu label Boot from ^local drive
  localboot 0xffff

menu separator # insert an empty line
menu separator # insert an empty line

label returntomain
  menu label Return to ^main menu
  menu exit

menu end
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
cp centos-7.ks /tmp/bootisoks/isolinux/ks.cfg
# sed -i 's/append\ initrd\=initrd.img$/append initrd=initrd.img\ ks\=cdrom:\/ks.cfg/' /tmp/bootisoks/isolinux/isolinux.cfg
cp isolinux.cfg /tmp/bootisoks/isolinux/isolinux.cfg
cd /tmp/bootisoks && mkisofs -o /tmp/boot.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64" -R -J -v -T isolinux/. .
implantisomd5 "/tmp/boot.iso"
cp /tmp/boot.iso $LOCAL_HOST/$ISO_NAME
