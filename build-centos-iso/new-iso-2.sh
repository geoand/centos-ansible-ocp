#!/usr/bin/env bash

LOCAL_HOST="/Users/dabou/images"
CENTOS_ISO="CentOS-7-x86_64-Minimal-1708.iso"
ISO_NAME="centos7"
ISO="$LOCAL_HOST/$CENTOS_ISO"
BUILD_DIR=/tmp/build
HOME_INSTALL=$(pwd)

echo "##### Create our own ISO ....."
echo "##### using $HOME_INSTALL/new-iso-2.sh script"

echo "##### Remove bootiso folder"
rm -rf /tmp/bootiso
rm -rf /tmp/build

echo "##### Make bootiso and build dirs"
mkdir /tmp/bootiso
mkdir /tmp/build

echo "##### Create iso using live-cdcreator"
cd $BUILD_DIR

sudo livecd-creator -v --config $HOME_INSTALL/config/centos-7-2.ks --logfile=$BUILD_DIR/livecd-creator.log --fslabel centos7
dd if=/dev/zero bs=2k count=1 of=${BUILD_DIR}/boot.iso
dd if=$BUILD_DIR/$ISO_NAME.iso bs=2k skip=1 >> ${BUILD_DIR}/tmp.iso
mv -f ${BUILD_DIR}/tmp.iso $BUILD_DIR/$ISO_NAME.iso

echo "##### Add md5 signature"
# TODO: Check if we can resolve this issue : ERROR: Could not find primary volumne!
# implantisomd5 $BUILD_DIR/$ISO_NAME.iso

echo "##### Copy iso file to your local_host : $LOCAL_HOST/$CENTOS_ISO"
cp $BUILD_DIR/$ISO_NAME.iso $LOCAL_HOST/$ISO_NAME.iso
