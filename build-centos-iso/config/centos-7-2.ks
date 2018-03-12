# Action
install
cdrom

# Run the Setup Agent on first boot
firstboot --enable

# Accept Eula
eula --agreed

# Keyboard layouts
keyboard --xlayouts='us'

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

# Shutdown after installing
shutdown

# Firewall configuration
firewall --disabled
selinux --enforcing

# Network information
# We can't setup IP fix. TODO: To be investigated
# network --bootproto=static --device=eth0 --onboot=on --ip=192.168.99.50 --netmask=255.255.255.0 --gateway=192.168.99.1 --nameserver=192.168.99.1 --nameserver=8.8.8.8
network --bootproto=dhcp --device=eth0 --activate --onboot=on
network --bootproto=dhcp --device=eth1 --activate --onboot=on

# System bootloader configuration
bootloader --timeout=1 --location=mbr --boot-drive=sda --append="no_timer_check console=ttyS0 console=tty0 net.ifnames=0 biosdevname=0"
autopart --type=lvm
zerombr

# Partition clearing information
clearpart --all --drives=sda
ignoredisk --only-use=sda

#Repos
repo --name=base --baseurl=http://mirror.centos.org/centos/7/os/x86_64/
repo --name=updates --baseurl=http://mirror.centos.org/centos/7/updates/x86_64/
repo --name=extras --baseurl=http://mirror.centos.org/centos/7/extras/x86_64/
repo --name=atomic --baseurl=http://mirror.centos.org/centos/7/atomic/x86_64/adb/

%packages  --excludedocs --instLangs=en --ignoremissing
@core
openssl
bash
docker # TODO Check why this package is not there during installation
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


#Packages to be removed
-aic94xx-firmware
-alsa-firmware
-iprutils
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware
-iwl7265-firmware
-postfix
-rsyslog
%end

%post
cat > \$LIVE_ROOT/isolinux/isolinux.cfg << EOF
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
  append initrd=initrd.img ks=cdrom:/ks.cfg ksdevice=eth1 inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet

label check
  menu label Test this ^media & install CentOS 7
  menu default
  kernel vmlinuz
  append initrd=initrd.img ks=cdrom:/ks.cfg ksdevice=eth1 inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet

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
  append initrd=initrd.img ks=cdrom:/ks.cfg  ksdevice=eth1 inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 xdriver=vesa nomodeset quiet

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
%end
