# Install OpenShift Cluster using ansible & CentOS VM provisioned on Virtualbox

- Create Virtualbox vm using the `up.sh` bash script
```bash
./up.sh
```

- Secure copy your public key
```bash
sshpass -f pwd.txt ssh -o StrictHostKeyChecking=no root@127.0.0.1 -p 5222 "mkdir ~/.ssh && chmod 700 ~/.ssh && touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
sshpass -f pwd.txt ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub root@127.0.0.1 -p 5222
```

- Git clone `openshihift-ansible` 
```bash
git clone -b release-3.7 https://github.com/openshift/openshift-ansible.git
```

- Import RPMs of OpenShift
```bash
ansible-playbook -i inventory playbook/install-package.yaml -e openshift_node=masters
```

# Authentication or permission failure. In some cases, you may have been able to authenticate and did not have permissions on the target directory.
# Consider changing the remote temp path in ansible.cfg to a path rooted in \"/tmp\"
remote_tmp = /tmp/.ansible-${USER}/tmp

- Create OpenShift cluster
```bash
ansible-playbook -i inventory openshift-ansible/playbooks/byo/config.yml
```

- Setup persistence
```bash
ansible-playbook -i inventory playbook/setup_persistence.yml -e openshift_node=masters
```
