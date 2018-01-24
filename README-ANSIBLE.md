Table of Contents
=================

   * [Istio Deployment on Kubernetes / OpenShift using Ansible](#istio-deployment-on-kubernetes-or-openshift-using-ansible)
      * [Prerequisites](#prerequisites)
      * [Execution](#execution)
      * [Typical use cases](#typical-use-cases)

# Istio Deployment on Kubernetes or OpenShift using Ansible

The Ansible scenario defined within this project will let you to : 

- Install `Istio` Distribution and set the path of the `istioctl` go client (if you execute the command manually)
- Deploy Istio on Openshift or Kubernetes by specifying different parameters (version, enable auth, deploy bookinfo, ...)
- Specify the addons to be deployed such as `Grafana`, `Prometheus`, `Servicegraph`, `Zipkin` or `Jaeger`

## Prerequisites

- [Ansible 2.4](http://docs.ansible.com/ansible/latest/intro_installation.html)

Refer to the Ansible Installation Doc on how to install Ansible on your machine.
To use locally `[Minishift](https://docs.openshift.org/latest/minishift/command-ref/minishift_start.html)` or `[Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/)`, please refer to their respective documentation. 

## Execution

The role assumes that the user :
- Can access a Kubernetes or Openshift cluster via `kubectl` or `oc` respectively and is authenticated against the cluster. 
- Connected to Openshift has the `admin` role on the OpenShift platform

Remark : Furthermore the minimum Kubernetes version that is compatible is `1.7.0` (`3.7.0` is the corresponding OpenShift version).   

**Important**: All invocations of the Ansible playbooks need to take place at the root directory of the project.
Failing to do so will result in unexpected errors 

The simplest execution command looks like the following:
 
```bash
ansible-playbook ansible/main.yml
```

Remarks:
- The role tries it's best to be idempotent, so running the playbook multiple times should be have the same effect as running it a single time.   
- The default parameters that apply to this role can be found in `istio/defaults/main.yml`.
- To change parameters from the command line use Ansible's syntax for doing so as is described [here](http://docs.ansible.com/ansible/latest/playbooks_variables.html#passing-variables-on-the-command-line)

An example of an invocation where we want to deploy Jaeger instead of Zipkin would be:
```bash
ansible-playbook ansible/main.yml -e '{"istio": {"jaeger": true}}'
```

The full list of configurable parameters is as follows:

| Parameter | Description | Values |
| --- | --- | --- |
| `cluster_flavour` | defines whether the target cluster is a Kubernetes or an Openshift cluster. | Valid values are `k8s` and `ocp` - default
| `cmd_path` | can be used when the user does not have the `oc` or `kubectl` binary on the PATH | Defaults to expecting the binary is on the path 
| `cluster_url` | should be used when the user wishes to deploy Istio on a remote Openshift cluster. The URL will be used by `oc login`. | 
| `istio.delete_resources` | should be set to true when an existing installation is already present on the cluster. By default this parameters is set to false and the playbook will fail if Istio has already been installed | `true` and `false` - default  
| `istio.release_tag_name` | should be a valid Istio release version. If let empty then the latest Istio release will be installed | `0.2.12`, `0.3.0`, `0.4.0` - default  
| `istio.dest` | The path on the local file system where the Istio release will be found | `~/.istio` - default  
| `istio.auth` | Whether TLS is enabled for Istio | `true` and `false` - default  
| `istio.namespace` | Namespace where istio will be installed | `istio-system` is the default  
| `istio.addon` | Which Istio addons should be installed as well | This field is an array field, which by default contains `grafana`, `prometheus`, `zipkin` and `servicegraph`  
| `istio.jaeger` | Whether or not Jaeger tracing should also be installed | `true` and `false` - default  
| `istio.bookinfo` | Whether or not to install Istio's Book Info showcase | `true` and `false` - default  
| `istio.bookinfo_namespace` | The namespace into which to install Book Info showcase | `bookinfo` is the default  
| `istio.open_apps` | Whether or not to open the user's browser and point to the various services | `true` and `false` - default  

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