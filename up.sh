#!/bin/bash
# written by Charles Moulliard
# 8-March-2018
#
# Variables below are passed to VBoxManage
# Modify appropriately
#
# You can ssh to the VM : ssh root@127.0.0.1 -p 5222
# user : root
# pwd : centos
#
ISO_NAME="centos7.iso"
ISO="$(pwd)/$ISO_NAME" # MiniShift ISO Image - https://github.com/minishift/minishift-centos-iso/releases/download/v1.7.0/minishift-centos7.iso
virtualbox_vm_name="CentOS-7.1" # VM Name
OSTYPE="Linux_64";
DISKSIZE=20480; #in MB
RAM=4096; #in MB
CPU=2;
CPUCAP=100;
PAE="on";
VRAM=8;
USB="off";

echo "Getting ISO image if not there"
if [ -f $ISO_NAME ]; then
   echo "######### ISO File $FILE exists."
else
   echo "######### Getting file"
   wget -O $ISO_NAME https://github.com/minishift/minishift-centos-iso/releases/download/v1.7.0/minishift-centos7.iso
fi

echo "######### Poweroff machine if it runs"
vboxmanage controlvm $virtualbox_vm_name poweroff
echo "######### .............. Done"

echo "######### unregister vm "$virtualbox_vm_name" and delete it"
vboxmanage unregistervm $virtualbox_vm_name --delete || echo "No VM by name ${virtualbox_vm_name}"

####################################################################
echo "######### Create vboxnet0 network and set dhcp server : 192.168.99.0/24"
vboxmanage hostonlyif remove vboxnet0
vboxmanage hostonlyif create
vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.99.1 --netmask 255.255.255.0
vboxmanage dhcpserver add --ifname vboxnet0 --ip 192.168.99.20 --netmask 255.255.255.0 --lowerip 192.168.99.50 --upperip 192.168.99.200
vboxmanage dhcpserver modify --ifname vboxnet0 --enable

##########################################
echo "######### Create VM"
vboxmanage createvm --name ${virtualbox_vm_name} --ostype "$OSTYPE" --register --basefolder=$HOME/VirtualBox\ VMs

# VirtualBox Network
vboxmanage modifyvm ${virtualbox_vm_name} \
        --nic1 hostonly --hostonlyadapter1 vboxnet0 \
        --nic2 nat

# VM Config
vboxmanage modifyvm ${virtualbox_vm_name} --memory "$RAM";
vboxmanage modifyvm ${virtualbox_vm_name} --boot1 dvd --boot2 disk --boot3 none --boot4 none;
vboxmanage modifyvm ${virtualbox_vm_name} --chipset piix3;
vboxmanage modifyvm ${virtualbox_vm_name} --ioapic on;
vboxmanage modifyvm ${virtualbox_vm_name} --mouse ps2;
vboxmanage modifyvm ${virtualbox_vm_name} --cpus "$CPU" --cpuexecutioncap "$CPUCAP" --pae "$PAE";
vboxmanage modifyvm ${virtualbox_vm_name} --hwvirtex off --nestedpaging off;

vboxmanage modifyvm ${virtualbox_vm_name} --vram "$VRAM";
vboxmanage modifyvm ${virtualbox_vm_name} --monitorcount 1;
vboxmanage modifyvm ${virtualbox_vm_name} --accelerate2dvideo off --accelerate3d off;
vboxmanage modifyvm ${virtualbox_vm_name} --audio none;
vboxmanage modifyvm ${virtualbox_vm_name} --hpet on;
vboxmanage modifyvm ${virtualbox_vm_name} --x2apic off;
vboxmanage modifyvm ${virtualbox_vm_name} --rtcuseutc on;
vboxmanage modifyvm ${virtualbox_vm_name} --nestedpaging on;
vboxmanage modifyvm ${virtualbox_vm_name} --hwvirtex on;

vboxmanage modifyvm ${virtualbox_vm_name} --clipboard bidirectional;
vboxmanage modifyvm ${virtualbox_vm_name} --usb "$USB";
vboxmanage modifyvm ${virtualbox_vm_name} --vrde on;

# VirtualBox HDD
echo "######### Create SATA storage"
vboxmanage storagectl ${virtualbox_vm_name} --name "SATA" --add sata --controller IntelAhci --bootable on --hostiocache on
echo "######### Attach ISO to SATA Controller as port 0"
vboxmanage storageattach ${virtualbox_vm_name} --storagectl "SATA" --type hdd --port 0 --device 0 --type dvddrive --medium $ISO
echo "######### Create vmdk HD"
vboxmanage createhd --filename $HOME/VirtualBox\ VMs/${virtualbox_vm_name}/disk.vmdk --size 5000 --format VMDK
echo "######### Attach vmdk to SATA Controller as port 1"
vboxmanage storageattach ${virtualbox_vm_name} --storagectl "SATA" --type hdd --port 1 --device 0 --medium $HOME/VirtualBox\ VMs/${virtualbox_vm_name}/disk.vmdk

vboxmanage startvm ${virtualbox_vm_name} --type headless
vboxmanage controlvm ${virtualbox_vm_name} natpf2 ssh,tcp,127.0.0.1,5222,,22

echo "######### Run 'vboxmanage list -l vms | less' to check configuration."
exit 0;
