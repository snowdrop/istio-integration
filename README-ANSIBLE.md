# Istio Deployment on OpenShift using Ansible

The Ansible scenario defined within this project will let you to : 

- Install optionally `Minishift` and a hypervisor on your machine such as Xhyve (Darwin) or Kvm (Red Hat). Configure the `/etc/hosts` file with the clusterIP address 
- Install `Istio` Distribution and register the `istioctl` go client under your path
- Configure the addons to be deployed in Istio such as `Grafana`, `Prometheus`, `Servicegraph`, `Jaeger` and their corresponding routes
- Deploy a sample project to play with Istio

## Prerequisites

- [Ansible 2.4](ttp://docs.ansible.com/ansible/latest/intro_installation.html)
- [Minishift Role](https://docs.ansible.com/ansible-container/openshift/minishift.html)

Ansible can be installed on your machine as defined within the installation doc while the minishift role 
can be deployed using `ansible-galaxy` as defined hereafter. This minishift role is only required
if you prefer to install minishift using amsible.

```bash
cd ~
mkdir roles
echo "export ANSIBLE_ROLES_PATH=~/roles" >>.bashrc
ansible-galaxy install chouseknecht.minishift-up-role
```

## Install Minishift (optional)

When the Ansible role is installed, then you can play with it to install, reinstall, restart an existing Minishift project
The parameters to be used to customize the scenario (delete, force install, restart) can be changed within the `etc/config.yaml` file. See `minishift` key 

```bash
ansible-playbook ansible/minishift/install.yml
```

## Install Istio and the Bookinfo project

Now, you can execute the next following playbooks in order to :

- Configure a Minishift vm for the demo and start it. The parameters to configure the VM are defined under the file `ansible/minishift/vars/vm_config.yaml`.
  The Ansible parameter `--ask-become-pass` is required in order to prompt you to give your root/sudo password
  as xhyve requires root access on your machine ! 
```bash
ansible-playbook ansible/main.yml --extra-vars="action=create-vm" --ask-become-pass
```

- Deploy Istio distribution on your laptop. By default, that will be the latest istio release
```bash
ansible-playbook ansible/main.yml --extra-vars="action=install-distro"
```

!! Remark: You must define the location of the folder where you will install istio distro using the `istio.dest` variable defined within the file `ansible/etc/config.yaml`

- Install Istio on Openshift as the bookinginfo app
```bash
ansible-playbook ansible/main.yml --extra-vars="action=install-istio"
```

- Open the different applications into your browser
```bash
ansible-playbook ansible/main.yml --extra-vars="action=launch"
```