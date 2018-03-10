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
network --bootproto=dhcp --device=eth0 --activate --onboot=on
network --bootproto=dhcp --device=eth1 --activate --onboot=on

# System bootloader configuration
bootloader --timeout=1 --location=mbr --boot-drive=sda --append="no_timer_check console=ttyS0 console=tty0 net.ifnames=0 biosdevname=0"
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
