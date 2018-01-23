Table of Contents
=================

   * [Istio Deployment on Kubernetes / OpenShift using Ansible](#istio-deployment-on-kubernetes-or-openshift-using-ansible)
      * [Prerequisites](#prerequisites)
      * [Execution](#execution)
      * [Typical use cases](#typical-use-cases)

# Istio Deployment on Kubernetes or OpenShift using Ansible

The Ansible scenario defined within this project will let you to : 

- Optionally install `Minishift` and a hypervisor on your machine such as Xhyve (Darwin) or Kvm (Red Hat, Debian). Configure the `/etc/hosts` file with the clusterIP address 
- Install `Istio` Distribution and register the `istioctl` go client under your path
- Configure the addons to be deployed in Istio such as `Grafana`, `Prometheus`, `Servicegraph`, `Jaeger` and their corresponding routes
- Deploy a sample project to play with Istio

## Prerequisites

- [Ansible 2.4](http://docs.ansible.com/ansible/latest/intro_installation.html)

Refer to the Ansible Installation Doc on how to install Ansible on your machine.
To use the minishift role to install Minishift, then use the
Ansible Galaxy command to install the role from the repository. 

```bash
cd ~
mkdir roles
echo "export ANSIBLE_ROLES_PATH=~/roles" >>.bashrc
ansible-galaxy install chouseknecht.minishift-up-role
```

- Kubernetes / Openshift cluster 

The role assumes that the user can access a Kubernetes or Openshift cluster via `kubectl` or `oc` respectively. 
Furthermore the minimum Kubernetes version that is compatible is `1.7.0` (`3.7.0` is the corresponding Openshift version).   

## Execution

**Important**: All invocations of the Ansible playbooks need to take place at the root directory of the project.
Failing to do so will result in unexpected errors 

 
 The simplest possible execution looks like the following:
 
 ```bash
 ansible-playbook ansible/main.yml
 ```

The role tries it's best to be idempotent, so running the playbook multiple times should be have the same effect as running it a single time.   

The default parameters that apply to this role can be found in `istio/defaults/main.yml`. The same overriding rules apply for this profile as for the `minishift` profile.
An example of an invocation would be:
```bash
ansible-playbook ansible/main.yml -e '{"istio": {"jaeger": true}}'
```

Remarks:

A few very important parameters are the following:
- `cluster_flavour` defines whether the target cluster is an upstream Kubernetes cluster or an Openshift cluster (which is the default). Valid values are `k8s` and `ocp`
- `cmd_path` can be used when the user does not have the `oc` or `kubectl` binary on the PATH and additionally the 
`run_minishift_role` parameter is set (or defaults) to false.
- `istio.delete_resources` should be set to true when an existing installation is already present on the cluster. By default this parameters is set to false and the playbook will fail if Istio has already been installed
- `cluster_url` should be used when the user wishes to deploy Istio on a remote Openshift cluster. The URL will be used by `oc login`.

Furthermore in case of Openshift, the role assumes that the user is able to login to the target Openshift cluster using `admin/admin` credentials

This playbook will take care of downloading and installing Istio locally on your machine, before deploying the necessary Kubernetes / Openshift
pods, services etc. on to the cluster

### Note on istio.delete_resources

Activating the `istio.delete_resources` flag will result in any Istio related resources being deleted from the cluster before Istio is reinstalled.

In order to avoid any inconsistency issues, this flag should only be used to reinstall the same version of Istio on a cluster. If a new version
of Istio need to be reinstalled, then it is advisable to delete the `istio-system` namespace before executing the playbook (in which case the 
`istio.delete_resources` flag does not need to be activated)  

## Typical use cases

The following commands are some examples of how a user could install Istio using this Ansible role

- User executes installs Istio accepting all defaults
```bash
ansible-playbook ansible/main.yml
```

- User installs Istio on to a Kubernetes cluster 
```bash
ansible-playbook ansible/main.yml -e '{"cluster_flavour": "k8s"}' 
```

- User installs Istio on to a Kubernetes cluster and the path to `kubectl` is expicitly set (perhaps it's not on the PATH)
```bash
ansible-playbook ansible/main.yml -e '{"cluster_flavour": "k8s", "cmd_path": "~/kubectl"}' 
```

- User has a non-local Openshift cluster and wants to install Istio on it
```bash
ansible-playbook ansible/main.yml -e '{"cluster_url": "host_ip"}'
```

- User wants to install Istio on Openshift with settings other than the default
```bash
ansible-playbook ansible/main.yml -e '{"istio": {"release_tag_name": "0.4.0", "auth": true, "jaeger": true, "delete_resources": true}}'
```

- User wants to install Istio on Openshift but with custom add-on settings
```bash
ansible-playbook ansible/main.yml -e '{"istio": {"delete_resources": true, "addons": ["grafana", "prometheus"]}}'
```

The list of available addons can be found at `ansible/istio/vars.main.yml` under the name `istio_all_addons`.
Jaeger is not installed using the `addons` property, but can be installed by enabling `"jaeger": true` like in one of the previous examples.
It should be noted that when Jaeger is enabled, Zipkin is disabled whether or not it's been selected in the addons section.