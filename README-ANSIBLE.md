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

## Install Istio and the Bookinfo project

Now, you can execute the following playbooks in order to :

1. Create a Minishift vm using the profile `istio-demo` and start it.
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

2. Deploy the Istio distribution on your laptop. By default, the latest istio [release](https://github.com/istio/istio/releases/) will be installed
```bash
ansible-playbook ansible/main.yml -t install-distro
```
You can change the version to be installed using the variable `istio.release_tag_name` defined under the file `ansible/etc/config.yaml`
! Remark: You must define the location of the folder where you will install istio distro using the `istio.dest` variable.

3. Install Istio on Openshift within the namespace `istio-system`. 
```bash
ansible-playbook ansible/main.yml -t install-istio
```

3. Install Bookinginfo app (optional)
```bash
ansible-playbook ansible/main.yml -t install-bookinfo
```

4. Open the different applications into your browser (optional)
```bash
ansible-playbook ansible/main.yml -t launch
```