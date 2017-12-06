Table of Contents
=================

   * [Istio Deployment on OpenShift using Ansible](#istio-deployment-on-openshift-using-ansible)
      * [Prerequisites](#prerequisites)
      * [Install Minishift (optional)](#install-minishift-optional)
      * [Install Istio and the Bookinfo project](#install-istio-and-the-bookinfo-project)
         * [Download and install istio distribution](#download-and-install-istio-distribution)
         * [Deploy Istio on OpenShift](#deploy-istio-on-openshift)
         * [Bookinfo Demo (optional)](#bookinfo-demo-optional)

# Istio Deployment on OpenShift using Ansible

The Ansible scenario defined within this project will let you to : 

- Install optionally `Minishift` and a hypervisor on your machine such as Xhyve (Darwin) or Kvm (Red Hat). Configure the `/etc/hosts` file with the clusterIP address 
- Install `Istio` Distribution and register the `istioctl` go client under your path
- Configure the addons to be deployed in Istio such as `Grafana`, `Prometheus`, `Servicegraph`, `Jaeger` and their corresponding routes
- Deploy a sample project to play with Istio

## Prerequisites

- [Ansible 2.4](ttp://docs.ansible.com/ansible/latest/intro_installation.html)
- [Minishift Role](https://docs.ansible.com/ansible-container/openshift/minishift.html)

Refer to the Ansible Installation Doc how to install Ansible on your machine.
To use the minishift role to install minishift, then use the
Ansible Galaxy command to install the role from the repository. 

Remark : This minishift role is only required if you prefer to install minishift using ansible.

```bash
cd ~
mkdir roles
echo "export ANSIBLE_ROLES_PATH=~/roles" >>.bashrc
ansible-galaxy install chouseknecht.minishift-up-role
```

## Install Minishift (optional)

When the Ansible Minishift role is installed, then you can play with it to install or reinstall Minishift.
The parameters used to customize the scenario can be changed within the `etc/config.yaml` file. See `minishift` key.

Here are the parameters defined for our config :

- minishift_repo: minishift/minishift # Repo where the minishift binary can be found
- minishift_github_url: https://api.github.com/repos
- minishift_release_tag_name: "" # Defaults to installing the latest release. Use to install a specific minishift release.
- minishift_dest: /usr/local/bin
- minishift_force_install: yes # Overwrite any existing minishift binary found at minishift_dest
- minishift_restart: no # Stop and recreate the existing minishift instance.
- minishift_delete: yes # Perform `minishift delete`, and remove `~/.minishift`. If you're upgrading, you most likely want to do this.
- minishift_start_options: []
- openshift_client_dest: /usr/local/bin
- openshift_force_client_copy: yes # Overwrite any existing OpenShift client binary found at {{ openshift_client_dest }}.

and the playbook to install Minishift. 

```bash
ansible-playbook ansible/minishift/install.yml
```

During the installation, the following tasks will be performed:

- Downloads and installs the latest minishift binary
- Copies the latest oc binary from ~/.minishift/cache/oc to a directory in your PATH
- Installs the Docker Machine driver
- Creates a minishift instance
- Grants cluster admin to the developer account
- Creates a route to the internal registry
- Adds a hostname to /etc/hosts for accessing the internal registry

## Install Istio platform

Now, you can execute the following playbooks in order to create a Minishift vm using the profile `istio-demo` and start it.
```bash
ansible-playbook ansible/main.yml -t create-vm --ask-become-pass
```

Remarks:

- If a minishift instance already exists, then it will be stopped and the vm deleted. The profile will not be deleted !
- The variables to configure the VM are defined under the file `ansible/etc/config.yaml`. See `profile/config`
  By default, they are defined as such :
  - memory: 3GB
  - image-caching: true
  - cpus: 2
  - vm-driver: xhyve
  - openshift-version: v3.7.0-rc.0
- The Ansible parameter `--ask-become-pass` is required in order to prompt you to give your root/sudo password
  as xhyve requires root access on your machine ! 

### Download and install istio distribution

To deploy the Istio distribution on your laptop, execute this ansible playbook. By default, the latest istio [release](https://github.com/istio/istio/releases/) will be installed
```bash
ansible-playbook ansible/main.yml -t install-distro
```
You can change the version to be installed using the variable `istio.release_tag_name` defined under the file `ansible/etc/config.yaml`
! Remark: You must define the location of the folder where you will install istio distro using the `istio.dest` variable.

### Deploy Istio on OpenShift 

To deploy the different components of the istio platform, then execute this plabook. It will install Istio on Openshift under the namespace `istio-system`. 
```bash
ansible-playbook ansible/main.yml -t install-istio
```
### Bookinfo Demo (optional)

- Install Bookinginfo app
```bash
ansible-playbook ansible/main.yml -t install-bookinfo
```

- Open the different applications into your browser
```bash
ansible-playbook ansible/main.yml -t launch
```