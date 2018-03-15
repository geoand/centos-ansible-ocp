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
##### 1. Add ssh public key and create user-data file
##### 2. Generating ISO file containing user-data, meta-data files and used by cloud-init at bootstrap
Total translation table size: 0
Total rockridge attributes bytes: 331
Total directory bytes: 0
Path table size(bytes): 10
Max brk space used 0
183 extents written (0 MB)
#### 3. Downloading  http://cloud.centos.org/centos/7/images//CentOS-7-x86_64-GenericCloud.qcow2c ....
--2018-03-15 08:06:15--  http://cloud.centos.org/centos/7/images//CentOS-7-x86_64-GenericCloud.qcow2c
Resolving cloud.centos.org (cloud.centos.org)... 162.252.80.138
Connecting to cloud.centos.org (cloud.centos.org)|162.252.80.138|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 394918400 (377M)
Saving to: '/Users/dabou/images/CentOS-7-x86_64-GenericCloud.qcow2c'

100%[===================================================================================================================================================================================================>] 394,918,400 2.81MB/s   in 3m 40s 

2018-03-15 08:09:56 (1.71 MB/s) - '/Users/dabou/images/CentOS-7-x86_64-GenericCloud.qcow2c' saved [394918400/394918400]

#### Optional - Resizing qcow2 Image - +20G
Image resized.
#### 4. Converting QCOW to VMDK format
    (100.00/100%)
Done
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
- Unregister vm "$VIRTUAL_BOX_NAME" and delete it
- Rename Centos vmdk to disk.vmdk
- Create vboxnet0 network and set dhcp server : 192.168.99.50/24
- Create VM
- Define NIC adapters; NAT and vboxnet0
- Customize vm; ram, cpu, ...
- Create IDE Controller, attach iso dvd and vmdk disk
- Start vm and configure SSH Port forward

```bash
./cloud-init/create-vm.sh
```

Test if you can ssh to the newly created vm !
```bash

```

TODO : Test Atomic Centos and Ansible -> http://www.projectatomic.io/docs/quickstart/