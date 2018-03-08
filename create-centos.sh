#!/bin/bash -e

#
# Prepare Centos ISO image, mount it and next create Virtulabox VM
#
echo "Starting `basename $0`"
box_os=CentOS
box_os_version=7.1

echo "Searching for grep ..."
which grep

echo "Searching for sed ..."
which sed

echo "Searching for VirtualBox ..."
which vboxmanage

echo "Searching for lftp ..."
which lftp

echo "Searching for fuseiso ..."
which fuseiso

echo "Searching for fusermount ..."
which fusermount

echo "Searching for gzip ..."
which gzip

echo "Searching for mkisofs ..."
which mkisofs

# As of 9 Nov 2015, there are 5 mirrors for centos in India
# Of those only, 1 is in Bombay/Mumbai (proximity to Pune)
mirror_url="http://centos.excellmedia.net/"
# TODO: Find metalink to pass to curl/aria2 for ISO

# Download filelist, then extract and figure ISO path
lftp -c "get ${mirror_url}/filelist.gz"
rm filelist || echo "No filelist to delete"
gzip -d filelist.gz

relative_iso_url=`grep -i minimal filelist | grep -i iso | grep -i ${box_os_version} | grep -v torrent | sed -e 's/^\.//'`
absolute_iso_url="${mirror_url}${relative_iso_url}"
absolute_iso_folder_url=`dirname ${absolute_iso_url}`
iso_filename=`basename ${absolute_iso_url}`

lftp -c "mirror --verbose --only-newer --parallel=4 --use-pget=4 --include=${iso_filename} ${absolute_iso_folder_url}"
# ISO will get downloaded to x86_64 folder
rm -r iso_extract || echo "No iso_extract" folder to clean
mkdir -p iso_extract

# Mount ISO
fuseiso ./x86_64/${iso_filename} ./iso_extract

chmod -R u+w iso_new || echo "No iso_new folder to make writable"
rm -r iso_new || echo "No iso_new folder to clean"
mkdir -p iso_new

lftp -c "mirror --parallel=8 --use-pget=8 file://`pwd`/iso_extract file://`pwd`/iso_new"
fusermount -u ./iso_extract

cp ks.cfg ./iso_new/
chmod +w ./iso_new/isolinux/isolinux.cfg
sed -r -i -e 's/^timeout [0-9]+/timeout 10/' -e '/menu default/d' ./iso_new/isolinux/isolinux.cfg
sed -r -i -e "s/label check/label custom\n  menu label ^Unattended install\n  kernel vmlinuz\n  menu default\n  append initrd=initrd.img ks=cdrom:\/ks.cfg in
st.stage2=hd:LABEL=${box_os}-${box_os_version}-Custom xvdriver=vesa nomodeset text\n\nlabel check/" ./iso_new/isolinux/isolinux.cfg

pushd iso_new
mkisofs -o ../${box_os}-${box_os_version}-Custom.iso -quiet -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J
 -R -V "${box_os}-${box_os_version}-Custom" .
 popd

# Create bare bones VM using VirtualBox
virtualbox_vm_name="CentOS-7.1-minimal"
vboxmanage unregistervm ${virtualbox_vm_name} || echo "No VM by name ${virtualbox_vm_name}"
rm -r VirtualBoxVM || echo "No VirtualBoxVM folder to clean"
mkdir -p VirtualBoxVM
vboxmanage createvm --name ${virtualbox_vm_name} --ostype "RedHat_64" --register --basefolder=`pwd`/VirtualBoxVM
vboxmanage createhd --filename `pwd`/VirtualBoxVM/${virtualbox_vm_name}.vdi --size 2048
vboxmanage storagectl ${virtualbox_vm_name} --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach ${virtualbox_vm_name} --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium `pwd`/VirtualBoxVM/${virtualbox_vm_name
}.vdi
vboxmanage storagectl ${virtualbox_vm_name} --name "IDE Controller" --add ide
vboxmanage storageattach ${virtualbox_vm_name} --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium `pwd`/${box_os}-${box_os_version}-C
ustom.iso
vboxmanage storageattach ${virtualbox_vm_name} --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium emptydrive
vboxmanage storageattach ${virtualbox_vm_name} --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium additions

vboxmanage modifyvm ${virtualbox_vm_name} --memory 512 --vram 12 --acpi on --ioapic on
vboxmanage modifyvm ${virtualbox_vm_name} --boot1 dvd --boot2 disk --boot3 none --boot4 none

echo "Unattended install start ..."
date
vboxmanage startvm ${virtualbox_vm_name} --type headless
# http://superuser.com/questions/547980/bash-script-to-wait-for-virtualbox-vm-shutdown
until $(vboxmanage showvminfo --machinereadable ${virtualbox_vm_name} | grep -q ^VMState=.poweroff.); do
    sleep 10
done
echo "Unattended install end ..."
date

vboxmanage storagectl ${virtualbox_vm_name} --name "IDE Controller" --remove
vboxmanage storagectl ${virtualbox_vm_name} --name "IDE Controller" --add ide
vboxmanage storageattach ${virtualbox_vm_name} --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium emptydrive

# No intention of uploading to atlas at the moment. Use any name.
vagrant package --base ${virtualbox_vm_name} --output my-centos7.1-vbguestadditions.box
vagrant box add --force --provider virtualbox --name "my/centos7.1-vbguestadditions" my-centos7.1-vbguestadditions.box

echo "Finished `basename $0`"
