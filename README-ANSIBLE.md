Table of Contents
=================

   * [Istio Deployment on Kubernetes / OpenShift using Ansible](#istio-deployment-on-kubernetes-or-openshift-using-ansible)
      * [Prerequisites](#prerequisites)
      * [Install Minishift (optional)](#install-minishift-optional)
      * [Install Istio and the Bookinfo project](#install-istio-and-the-bookinfo-project)
      * [Typical use cases](#typical-use-cases)

# Istio Deployment on Kubernetes or OpenShift using Ansible

The Ansible scenario defined within this project will let you to : 

- Optionally install `Minishift` and a hypervisor on your machine such as Xhyve (Darwin) or Kvm (Red Hat, Debian). Configure the `/etc/hosts` file with the clusterIP address 
- Install `Istio` Distribution and register the `istioctl` go client under your path
- Configure the addons to be deployed in Istio such as `Grafana`, `Prometheus`, `Servicegraph`, `Jaeger` and their corresponding routes
- Deploy a sample project to play with Istio

## Prerequisites

- [Ansible 2.4](http://docs.ansible.com/ansible/latest/intro_installation.html)
- [Minishift Role](https://docs.ansible.com/ansible-container/openshift/minishift.html)

Refer to the Ansible Installation Doc on how to install Ansible on your machine.
To use the minishift role to install Minishift, then use the
Ansible Galaxy command to install the role from the repository. 

```bash
cd ~
mkdir roles
echo "export ANSIBLE_ROLES_PATH=~/roles" >>.bashrc
ansible-galaxy install chouseknecht.minishift-up-role
```

If Minishift is not going to being used to deploy an Openshift cluster and instead the Istio role will be used against a running Openshift or Kubernetes cluster, 
that cluster must be a Kubernetes version of `1.7.0` or higher. This is necessary since some of Istio's features only work on such clusters.

## Roles

**Important**: All invocations of the Ansible playbooks need to take place at the root directory of the project.
Failing to do so will result in unexpected errors 

This playbook contains two roles:
- minishift
- istio

To only execute the `minishift` role, one would use a command like the following:

 ```bash
 ansible-playbook ansible/main.yml -t minishift
 ```
 
 To execute the `istio` role, use
 
 ```bash
 ansible-playbook ansible/main.yml -t istio
 ```
 
It should be noted that the `minishift` role can be a dependency of the `istio` role, meaning that when Ansible tries to execute the latter,
it will first execute the former.

Each role tries it's best to be idempotent, so running the playbook multiple times should be have the same effect as running it a single time.   

## Install Minishift (optional)

When the `minishift` role is used, then you can play with it to install Minishift and create a VM that will be used to deploy Istio.

The default parameters that apply to this role can be found in `minishift/defaults/main.yml`. 
Any of these parameters can be changed on the command line using Ansible's support for overriding parameters using JSON syntax
(see [documentation](http://docs.ansible.com/ansible/latest/playbooks_variables.html#passing-variables-on-the-command-line) for more details).
If for example the user wants to use a specific Minishift profile name and also increase the memory used (while keeping the defaults for all other parameters)
he/she could execute the following command:

```bash
ansible-playbook ansible/main.yml -t minishift -e '{"minishift": {"profile": {"name": "test", "config": {"memory": "4GB"}}}}'
```

Remarks:


- The default profile used is named `istio-demo`.
- The variables to configure the VM are defined under the file `minishift/defaults/main.yml`. See `minishift/profile/config`
  By default, they are defined as such :
  - memory: 3GB
  - image-caching: true
  - cpus: 2
  - vm-driver: xhyve
  - openshift-version: v3.7.0
- If Minishift is already running as a VM in the specified profile, that VM will be used
- The Ansible parameter `--ask-become-pass` is required in order to prompt you to give your root/sudo password
  as xhyve requires root access on your machine ! 

In addition to the parameters supported by the role, you can also configure the parameters found [here](https://github.com/chouseknecht/minishift-up-role/blob/v1.0.11/defaults/main.yml)
that control how Minishift is installed on your system. 

## Install Istio platform

The default parameters that apply to this role can be found in `istio/defaults/main.yml`. The same overriding rules apply for this profile as for the `minishift` profile.
An example of an invocation would be:
```bash
ansible-playbook ansible/main.yml -t istio -e '{"istio": {"jaeger": true}}'
```

Remarks:

A few very important parameters are the following:
- `run_minishift_role` which defaults to `false`. In set to `true`, then Ansible will run the
`minishift` role to create the VM locally, before attempting to install Istio on it. When the parameter is `false` then 
it is assumed that the user has already configured the `oc` binary to point to a running / compatible Openshift cluster.
- `cluster_flavour` defines whether the target cluster is an upstream Kubernetes cluster or an Openshift cluster (which is the default). Valid values are `k8s` and `ocp`
- `cmd_path_override` can be used when the user does not have the `oc` or `kubectl` binary on the PATH and additionally the 
`run_minishift_role` parameter is set (or defaults) to false.
- `cluster_url` should be used when the user wishes to deploy Istio to a remote cluster. For this setting to work `oc` or `kubectl` must be pre-configured to have access to the cluster
- `istio.delete_resources` should be set to true when an existing installation is already present on the cluster. By default this parameters is set to false and the playbook will fail if Istio has already been installed

Furthermore in case of Openshift, the role assumes that the user is able to login to the target Openshift cluster using `admin/admin` credentials

This playbook will take care of downloading and installing Istio locally on your machine, before deploying the necessary Kubernetes / Openshift
pods, services etc. on to the cluster

### Note on istio.delete_resources

Activating the `istio.delete_resources` flag will result in any Istio related resources being deleted from the cluster before Istio is reinstalled.

In order to avoid any inconsistency issues, this flag should only be used to reinstall the same version of Istio on a cluster. If a new version
of Istio need to be reinstalled, then it is advisable to delete the `istio-system` namespace before executing the playbook (in which case the 
`istio.delete_resources` flag does not need to be activated)  

## Typical use cases

Following are the simplest commands one could execute to play with the demo for some typical use cases

- User does not have Minishift installed locally and want's to install it and use it to install istio :
```bash
ansible-playbook ansible/main.yml -t istio -e '{"run_minishift_role": true}'
```

- User already has Minishift installed and wants to use it to install Istio on the local Openshift
```bash
ansible-playbook ansible/main.yml -t istio
```

- User already has a `kubectl` configured to access a Kubernetes cluster and wants to install Istio on it 
```bash
ansible-playbook ansible/main.yml -t istio e '{"cluster_flavour": "k8s"}' 
```

- User has a non-local Openshift cluster and wants to it to install Istio
```bash
ansible-playbook ansible/main.yml -t istio -e '{"cluster_url": "host:ip"}'
```

- User wants to install Istio on Minishift with settings other than the default
```bash
ansible-playbook ansible/main.yml -t istio -e '{"istio": {"release_tag_name": "0.4.0", "auth": true, "jaeger": true, "delete_resources": true}}'
```

- User wants to install Istio on Minishift and wants to customize the Istio addons
```bash
ansible-playbook ansible/main.yml -t istio -e '{"istio": {"delete_resources": true, "addons": ["grafana", "prometheus"]}}'
```

The list of available addons can be found at `ansible/istio/vars.main.yml` under the name `istio_all_addons`.
Jaeger is not installed using the `addons` property, but can be installed by enabling `"jaeger": true` like in one of the previous examples.
It should be noted that when Jaeger is enabled, Zipkin is disabled whether or not it's been selected in the addons section.