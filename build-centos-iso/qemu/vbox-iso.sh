#!/bin/bash

IMAGE_DIR="/Users/dabou/images"
CENTOS_QCOW2="CentOS-7-x86_64-GenericCloud-1802.qcow2c"
OS_NAME="centos7"

##
## generate the config-drive iso
##
gen_iso(){
    echo "Generating ISO"
    genisoimage -output ${IMAGE_DIR}/vbox-config.iso -volid cidata -joliet -r meta-data user-data
}

##
## Resize as necessary
##
resize(){
    echo "Resizing Image"
    qemu-img resize ${IMAGE_DIR}/${CENTOS_QCOW2} +20G
}
##
## Convert the qcow to vmdk
##
make_vmdk(){
    echo "Converting QCOW to VMDK"
    qemu-img convert -f qcow2 ${IMAGE_DIR}/${CENTOS_QCOW2} -O vmdk ${IMAGE_DIR}/${OS_NAME}.vmdk
}

gen_iso
resize
make_vmdk
echo "Done"
