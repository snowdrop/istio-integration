# Istio Deployment on OpenShift

The following [blog article](https://blog.openshift.com/evaluate-istio-openshift/) details how to install OpenShift. The scenario defined hereafter should be revisited

## Install istio bin locally
```bash
curl -L https://git.io/getLatestIstio | sh -
```

## Launch OpenShift on your laptop

Remark : the version 3.7.0 of OpenShift is at least required

```bash
minishift profile set istio-demo
minishift config set memory 4GB
minishift config set cpus 2
minishift config set vm-driver xhyve
minishift addon enable admin-user
minishift config set openshift-version v3.7.0-rc.0
minishift start 
eval $(minishift oc-env)
```

## Log to the OpenShift platform and create the project

```bash
eval $(minishift oc-env)
oc login -u admin -p admin

oc new-project istio-system
```

## Deploy Istio

```bash
# Not used - Do we need them !!
oc adm policy add-scc-to-user anyuid -z default -n istio-system
oc adm policy add-scc-to-user privileged -z default -n istio-system
oc adm policy add-cluster-role-to-user cluster-admin -z default -n istio-system
oc adm policy add-cluster-role-to-user cluster-admin -z istio-pilot-service-account -n istio-system
oc adm policy add-cluster-role-to-user cluster-admin -z istio-ingress-service-account -n istio-system
oc adm policy add-cluster-role-to-user cluster-admin -z istio-egress-service-account -n istio-system
oc adm policy add-cluster-role-to-user cluster-admin -z istio-mixer-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
oc adm policy add-scc-to-user privileged -z istio-ingress-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-egress-service-account -n istio-system
oc adm policy add-scc-to-user privileged -z istio-egress-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account -n istio-system
oc adm policy add-scc-to-user privileged -z istio-pilot-service-account -n istio-system

# Should be according to Veer - To be checked
oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-egress-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z default -n istio-system
oc adm policy add-scc-to-user privileged -z default -n bookinfo

# Clean up step (optional)
oc delete clusterroles "istio-pilot-istio-system"
oc delete clusterroles "istio-initializer-istio-system"
oc delete clusterroles "istio-mixer-istio-system"
oc delete clusterroles "istio-ca-istio-system"
oc delete clusterroles "istio-sidecar-istio-system"
oc delete clusterrolebindings "istio-pilot-admin-role-binding-istio-system"
oc delete clusterrolebindings "istio-initializer-admin-role-binding-istio-system"
oc delete clusterrolebindings "istio-ca-role-binding-istio-system"
oc delete clusterrolebindings "istio-ingress-admin-role-binding-istio-system"
oc delete clusterrolebindings "istio-egress-admin-role-binding-istio-system"
oc delete clusterrolebindings "istio-sidecar-role-binding-istio-system"
oc delete clusterrolebindings "istio-mixer-admin-role-binding-istio-system"
oc delete customresourcedefinitions.apiextensions.k8s.io "rules.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "attributemanifests.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "deniers.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "listcheckers.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "memquotas.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "noops.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "prometheuses.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "stackdrivers.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "statsds.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "stdios.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "svcctrls.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "checknothings.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "listentries.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "logentries.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "metrics.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "quotas.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "reportnothings.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "destinationpolicies.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "egressrules.config.istio.io"
oc delete customresourcedefinitions.apiextensions.k8s.io "routerules.config.istio.io"
oc delete namespaces "istio-system"
oc delete configmaps "istio-mixer"
oc delete services "istio-mixer"
oc delete serviceaccounts "istio-mixer-service-account"
oc delete deployments.extensions "istio-mixer"
oc delete configmaps "istio"
oc delete services "istio-pilot"
oc delete serviceaccounts "istio-pilot-service-account"
oc delete deployments.extensions "istio-pilot"
oc delete services "istio-ingress"
oc delete serviceaccounts "istio-ingress-service-account"
oc delete deployments.extensions "istio-ingress"
oc delete services "istio-egress"
oc delete serviceaccounts "istio-egress-service-account"
oc delete deployments.extensions "istio-egress"
oc delete serviceaccounts "istio-ca-service-account"
oc delete deployments.extensions "istio-ca"

# Deployment
ISTIO_DIR=$(find . -name \*istio\* -type d -maxdepth 1 -print -quit)
oc create -f $ISTIO_DIR/install/kubernetes/istio.yaml

# Message reported
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=stdio
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=logentry
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=metric
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=metric
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=metric
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=metric
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=metric
unable to recognize "./istio-0.2.12/install/kubernetes/istio.yaml": no matches for config.istio.io/, Kind=metric

oc expose svc istio-ingress

oc apply -f $ISTIO_DIR/install/kubernetes/addons/prometheus.yaml
oc apply -f $ISTIO_DIR/install/kubernetes/addons/grafana.yaml
oc apply -f $ISTIO_DIR/install/kubernetes/addons/servicegraph.yaml

oc expose svc servicegraph
oc expose svc grafana

oc apply -f <($ISTIO_DIR/bin/istioctl kube-inject -f $ISTIO_DIR/samples/bookinfo/kube/bookinfo.yaml)

oc expose svc productpage
```
