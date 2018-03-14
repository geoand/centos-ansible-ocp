#!/bin/bash

LOCAL_HOME_DIR=$1
IMAGE_DIR=${LOCAL_HOME_DIR}/images
CENTOS_QCOW2="CentOS-7-x86_64-GenericCloud-1802.qcow2c"
OS_NAME="centos7"

##
## Add public key
##
add_ssh_key(){
    echo "##### Add public key and create user-data file"
    YOUR_SSH_KEY=$(cat ${LOCAL_HOME_DIR}/.ssh/id_rsa.pub)
    sed "s|SSH_PUBLIC_KEY|${YOUR_SSH_KEY}|g" user-data.tpl > user-data
}

##
## generate the config-drive iso
##
gen_iso(){
    echo "##### Generating ISO"
    genisoimage -output ${IMAGE_DIR}/vbox-config.iso -volid cidata -joliet -r meta-data user-data
}

##
## Resize as necessary
##
resize(){
    echo "#### Resizing Image ....."
    qemu-img resize ${IMAGE_DIR}/${CENTOS_QCOW2} +20G
}
##
## Convert the qcow to vmdk
##
make_vmdk(){
    echo "#### Converting QCOW to VMDK ...."
    rm ${IMAGE_DIR}/${OS_NAME}.vmdk && touch ${IMAGE_DIR}/${OS_NAME}.vmdk
    qemu-img convert -p -f qcow2 ${IMAGE_DIR}/${CENTOS_QCOW2} -O vmdk ${IMAGE_DIR}/${OS_NAME}.vmdk
}

add_ssh_key
gen_iso
#resize
make_vmdk
echo "Done"
