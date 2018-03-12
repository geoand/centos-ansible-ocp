# Install OpenShift Cluster using ansible & CentOS VM provisioned on Virtualbox

## Modify CentOS ISO
- Create iso
```bash
vagrant plugin install vagrant-vbguest
vagrant plugin install sshd
cd build-centos-iso
vagrant up
```

Remark : Vagrant machine is only required for MacOs's user ! Otherwise skip these steps and execute directly the bash script to create the iso image

- Ssh to the vm. 
```bash
vagrant ssh
```
- Change the destination folder pointing to your local `home/images` folder where the iso generated file will be created.
  Edit the `install/new-iso.sh` bash script to change `LOCAL_PATH` parameter. Save it and run the script.
```bash
cd install && ./new-iso.sh
cd ..
```
- The new ISO image has been created locally on your local machine under `$HOME/images`
- Create new vm on your Virtualbox, using the script `./create_vm.sh` with the newly CentOS ISO image created
```bash
./create-vm.sh
```

## Use Minishift CentOS image
- Create Virtualbox vm using the `up.sh` bash script
```bash
./up.sh
```

# Installation

- Secure copy your public key
```bash
ssh-keygen -R "[127.0.0.1]:5222"
sshpass -f pwd.txt ssh -o StrictHostKeyChecking=no root@127.0.0.1 -p 5222 "mkdir ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
sshpass -f pwd.txt ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub root@127.0.0.1 -p 5222
```

- Add docker package as Centos kickstart can't install it during vm creation
```bash
ssh root@127.0.0.1 -p 5222 "yum -y install docker python-rhsm-certificates"
```

- Git clone `openshihift-ansible` 
```bash
git clone -b release-3.7 https://github.com/openshift/openshift-ansible.git
```

- Import RPMs of OpenShift
```bash
ansible-playbook -i inventory playbook/install-package.yaml -e openshift_node=masters
```

Remark : As rpms packages could be not be uploaded yum correctly the first time, then re-execute the command !

- Create OpenShift cluster
```bash
ansible-playbook -i inventory openshift-ansible/playbooks/byo/config.yml
```

Remarks:
- If, during the execution of this playbook, ASB playbook will report an error, then relaunch this playbook.

- Post installation steps 

  - Enable cluster admin role for `admin` user
  - Setup persistence using `HostPath` mounted volumes `/tmp/pv001 ...`, 
  - Create `infra` project
  - Install Nexus
  - Install Jenkins
  
Remark : As the `APB` pods will not be deployed correctly, Then relaunch the `APB` and `APB etcd` deployments from the console or terminal  
  
```bash
ansible-playbook -i inventory playbook/post_installation.yml -e openshift_node=masters
```
