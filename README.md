# Install an OpenShift All-in-one cluster on a CentOS VM

The following document explains how you can create a customized CentOS Generic Cloud qcow2 image and repackaged it as `vmdk` file. 

## Instructions to create a CentOS ISO Image

### MacOS's users only

As MacOS users can't execute natively all the linux commands, part of the different bash scripts, then it is required to create a Linux vm on virtualbox

- Create and start a vm on virtualbox
```bash
cd build-centos-iso
vagrant plugin install vagrant-vbguest
vagrant plugin install sshd
vagrant up
vagrant ssh
```

- Move to the `install` directory mounted into the vm by vagrant
```bash
cd install 
```

### Common steps

In order to prepare the Centos VM for the cloud we are using the `[cloud-init](http://cloudinit.readthedocs.io/en/latest)` tool which is a
set of python scripts and utilities to make your cloud images be all they can be! 

This tool will be then used to add to the Cloud image that we will install on Virtualbox, your own parameters such as :

- Network configuration (NAT, vboxnet),
- User : `root`, pwd : `centos`
- Additonnal non root user, user, password, ssh authorized key, 
- yum packages, ...


Remark : Centos 7 ISO packages by default the version `0.7.9` of the `cloud-init` tool 

To prepare your CentOS image like also the `iso` file that virtualbox will use to bootstrap your vm, you will have to execute the following script. It will perform these tasks :

- Add your SSH public key within the `user-data` fiel using as input the `user-data.tpl` file 
- Package the files `user-data` and `meta-data` within an ISO file created using `genisoimage` application
- Convert the `qcow2` Centos ISO image to `vmdk` file format

Execute this bash script to repackage the CentOS ISO image and pass as parameter your `</LOCAL/HOME/DIR>` and the name of the Generic Cloud Centos file `<QCOW2_IMAGE_NAME>` to be downloaded
from the site `http://cloud.centos.org/centos/7/images/`

```bash
cd cloud-init
./new-iso.sh </LOCAL/HOME/DIR> <QCOW2_IMAGE_NAME> <BOOLEAN_RESIZE_QCOQ_IMAGE>

e.g
./new-iso.sh /Users/dabou CentOS-7-x86_64-GenericCloud.qcow2c true

```
The new ISO image is created locally on your machine under this folder `$HOME/images`
```bash
ls -la $HOME/images
-rw-r--r--@   1 dabou  staff         6148 Mar 15 09:06 .DS_Store
-rw-r--r--    1 dabou  staff     61675897 Mar 15 09:06 CentOS-7-x86_64-GenericCloud.qcow2c
-rw-r--r--    1 dabou  staff            0 Mar 15 09:06 centos7.vmdk
-rw-r--r--    1 dabou  staff       374784 Mar 15 09:06 vbox-config.iso
```

### Create vm on Virtualbox

To create automatically a new Virtualbox VM using the CentOS ISO image customized, the iso file including the `cloud-init` config files, then execute the
following script `create_vm.sh`. This script will perform the following tasks:

- Poweroff machine if it runs
- unregister vm "$VIRTUAL_BOX_NAME" and delete it
- Copy disk.vmdk created"
- Create vboxnet0 network and set dhcp server : 192.168.99.50/24
- Create VM"
- Define NIC adapters; NAT and vboxnet0
- Customize vm; ram, cpu, ...
- Create IDE Controller, attach vmdk disk and iso dvd
- start vm and configure SSH Port forward

```bash
./cloud-init/create-vm.sh
```

Test if you can ssh to the newly created vm !
```bash

```

TODO : Test Atomic Centos and Ansible -> http://www.projectatomic.io/docs/quickstart/