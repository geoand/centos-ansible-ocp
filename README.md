# Install OpenShift Cluster using ansible & CentOS VM provisioned on Virtualbox

- Create Virtualbox vm using the `up.sh` bash script
```bash
./up.sh
```

- Secure copy your public key
```bash
sshpass -f pwd.txt ssh root@127.0.0.1 -p 5222 "mkdir ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
sshpass -f pwd.txt ssh-copy-id -n -i ~/.ssh/id_rsa.pub root@127.0.0.1 -p 5222
```

# - Install Python3
# ```bash
# ssh root@127.0.0.1 -p 5222 "yum -y install https://centos7.iuscommunity.org/ius-release.rpm && yum -y install python36u"
# ```

- Git clone `openshihift-ansible` 
```bash
git clone -b release-3.7 https://github.com/openshift/openshift-ansible.git
```

- Import RPMs of OpenShift
```bash
ansible-playbook -i inventory playbook/install-package.yaml -e openshift_node=masters
```

- Docker issue reported concernoing storage driver
  
  "Docker storage drivers 'overlay' and 'overlay2' are only supported with  'xfs' as the backing storage, but this host's storage is type 'extfs'"
  ```bash
  ssh root@127.0.0.1 -p 5222 "systemctl stop docker"
  ```

# - Enable NetworkManager
# ```bash
# ansible-playbook -i inventory playbook/enable_network-manager.yml -e openshift_node=masters
# ```

- Create OpenShift cluster
```bash
ansible-playbook -i inventory openshift-ansible/playbooks/byo/config.yml
```

- Enable NetworkManager
```bash
ansible-playbook -i inventory playbook/enable_cluster_admin.yml -e openshift_node=masters
```

- Setup persistence
```bash
ansible-playbook -i inventory playbook/setup_persistence.yml -e openshift_node=masters
```
