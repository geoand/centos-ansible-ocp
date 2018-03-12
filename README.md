# Install OpenShift Cluster using ansible & CentOS VM provisioned on Virtualbox

## Modify CentOS ISO
- Create iso
```bash
vagrant plugin install vagrant-vbguest
vagrant plugin install sshd
cd build-centos-iso
vagrant up
```

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

- Create OpenShift cluster
```bash
ansible-playbook -i inventory openshift-ansible/playbooks/byo/config.yml
```

- Post installation steps 

  - Add Red Hat Subscription Manager certificate
  - Enable cluster admin role for `admin` user
  - Setup persistence using Host mount points, 
  - Create `infra` project
  - Install Nexus
  - Install Jenkins
  
```bash
ansible-playbook -i inventory playbook/post_installation.yml -e openshift_node=masters
```
