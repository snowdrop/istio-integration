# Istio Deployment on OpenShift using Ansible

- Install Minishift on your laptop using Ansible Minishift role 

See [minishift role](https://docs.ansible.com/ansible-container/openshift/minishift.html) instructions and prerequisites to install the role
your machine

```bash
cd ~
mkdir roles
echo "export ANSIBLE_ROLES_PATH=~/roles" >>.bashrc
ansible-galaxy install chouseknecht.minishift-up-role
```

and execute the following command to install it

```bash
ansible-playbook ansible/minishift/install.yml
```

- Now, you can run the following playbook to configure minishift vm and install istio
```bash
ansible-playbook ansible/main.yml
```