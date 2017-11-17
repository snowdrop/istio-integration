# Istio Deployment on OpenShift using Ansible

The Ansible scenario defined within this project will let you to : 

- Install `Minishift` and a hypervisor on your machine such as Xhyve (Darwin) or Kvm (Red Hat). Configure the `/etc/hosts` file with the clusterIP address 
- Install `Istio` Distribution and register the `istioctl` go client under your path
- configure the addons to be deployed in Istio such as `Grafana`, `Prometheus`, `Servicegraph`, `Jaeger` and their corresponding routes
- Deploy a sample project to play with Istio

More informations about the minishift ansible role are available [minishift role](https://docs.ansible.com/ansible-container/openshift/minishift.html) like also the prerequisites 
and instructions to install the role on your machine.

Here is what you will do to install the role

```bash
cd ~
mkdir roles
echo "export ANSIBLE_ROLES_PATH=~/roles" >>.bashrc
ansible-galaxy install chouseknecht.minishift-up-role
```

## Install Minishift

When the Ansible role is installed, then you can play with it to install, reinstall, restart an existing Minishift project
The parameters to be used to customize the scenarion (delete, force install, restart) can be changed within the `etc/config.yaml` file. See `minishift` key 

```bash
ansible-playbook ansible/minishift/install.yml
```

## Install Istio and the sample project

Now, you can execute the next following playbooks in order to :

- Configure Minishift for the demo and start it
```bash
ansible-playbook ansible/main.yml --extra-vars="action=create-vm"
```

- Deploy Istio distribution on your laptop. By default, that will be the latest istio release
```bash
ansible-playbook ansible/main.yml --extra-vars="action=install-distro, istio.dest=# /Users/dabou/Code/snowdrop/istio-integration"
```

Remark: You can change the location of the folder where you want to install istio using the `istio.dest` variable defined within the file `ansible/etc/config.yaml`

- Install Istio on Openshift as the bookinginfo app
```bash
ansible-playbook ansible/main.yml --extra-vars="action=install-istio"
```

- Open the different applications into your browser
```bash
ansible-playbook ansible/main.yml --extra-vars="action=launch"
```