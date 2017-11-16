# Istio Deployment on OpenShift

The following [blog article](https://blog.openshift.com/evaluate-istio-openshift/) details how to install OpenShift.

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

## Log to the OpenShift platform

```bash
eval $(minishift oc-env)
oc login -u admin -p admin
```

## Install istio bin locally
```bash
curl -L https://git.io/getLatestIstio | sh -
```

## Deploy Istio

```bash
# As used by Burr Sutter
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

# Blog Article refers to define such security rules
oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account
oc adm policy add-scc-to-user privileged -z istio-ingress-service-account
oc adm policy add-scc-to-user anyuid -z istio-egress-service-account
oc adm policy add-scc-to-user privileged -z istio-egress-service-account
oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account
oc adm policy add-scc-to-user privileged -z istio-pilot-service-account
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user privileged -z default
oc adm policy add-cluster-role-to-user cluster-admin -z default

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
oc delete customresourcedefinitions "rules.config.istio.io"
oc delete customresourcedefinitions "attributemanifests.config.istio.io"
oc delete customresourcedefinitions "deniers.config.istio.io"
oc delete customresourcedefinitions "listcheckers.config.istio.io"
oc delete customresourcedefinitions "memquotas.config.istio.io"
oc delete customresourcedefinitions "noops.config.istio.io"
oc delete customresourcedefinitions "prometheuses.config.istio.io"
oc delete customresourcedefinitions "stackdrivers.config.istio.io"
oc delete customresourcedefinitions "statsds.config.istio.io"
oc delete customresourcedefinitions "stdios.config.istio.io"
oc delete customresourcedefinitions "svcctrls.config.istio.io"
oc delete customresourcedefinitions "checknothings.config.istio.io"
oc delete customresourcedefinitions "listentries.config.istio.io"
oc delete customresourcedefinitions "logentries.config.istio.io"
oc delete customresourcedefinitions "metrics.config.istio.io"
oc delete customresourcedefinitions "quotas.config.istio.io"
oc delete customresourcedefinitions "reportnothings.config.istio.io"
oc delete customresourcedefinitions "destinationpolicies.config.istio.io"
oc delete customresourcedefinitions "egressrules.config.istio.io"
oc delete customresourcedefinitions "routerules.config.istio.io"
oc delete configmaps "istio-mixer"
oc delete services "istio-mixer"
oc delete serviceaccounts "istio-mixer-service-account"
oc delete deployments "istio-mixer"
oc delete configmaps "istio"
oc delete services "istio-pilot"
oc delete serviceaccounts "istio-pilot-service-account"
oc delete deployments "istio-pilot"
oc delete services "istio-ingress"
oc delete serviceaccounts "istio-ingress-service-account"
oc delete deployments "istio-ingress"
oc delete services "istio-egress"
oc delete serviceaccounts "istio-egress-service-account"
oc delete deployments "istio-egress"
oc delete serviceaccounts "istio-ca-service-account"
oc delete deployments "istio-ca"
oc project default
oc delete namespaces "istio-system"
oc delete project istio-system --force=true --grace-period=0

# Deployment
oc new-project istio-system
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

OR

Error from server (AlreadyExists): error when creating "./istio-0.2.12/install/kubernetes/istio.yaml": namespaces "istio-system" already exists
Error from server (NotFound): error when creating "./istio-0.2.12/install/kubernetes/istio.yaml": the server could not find the requested resource (post stdios.config.istio.io)
Error from server (NotFound): error when creating "./istio-0.2.12/install/kubernetes/istio.yaml": the server could not find the requested resource (post logentries.config.istio.io)
Error from server (NotFound): error when creating "./istio-0.2.12/install/kubernetes/istio.yaml": the server could not find the requested resource (post metrics.config.istio.io)
Error from server (NotFound): error when creating "./istio-0.2.12/install/kubernetes/istio.yaml": the server could not find the requested resource (post metrics.config.istio.io)
Error from server (NotFound): error when creating "./istio-0.2.12/install/kubernetes/istio.yaml": the server could not find the requested resource (post metrics.config.istio.io)
Error from server (NotFound): error when creating "./istio-0.2.12/install/kubernetes/istio.yaml": the server could not find the requested resource (post metrics.config.istio.io)

# Add grafana, servicegraph, prometheus, zipkin

oc expose svc istio-ingress

oc create -f $ISTIO_DIR/install/kubernetes/addons/prometheus.yaml
oc create -f $ISTIO_DIR/install/kubernetes/addons/grafana.yaml
oc create -f $ISTIO_DIR/install/kubernetes/addons/servicegraph.yaml
oc create -f install/kubernetes/addons/zipkin.yaml

oc expose svc servicegraph
oc expose svc grafana
oc expose svc zipkin

SERVICEGRAPH=$(oc get route servicegraph -o jsonpath='{.spec.host}{"\n"}')
GRAFANA=$(oc get route grafana -o jsonpath='{.spec.host}{"\n"}')/dotviz
ZIPKIN=$(oc get route zipkin -o jsonpath='{.spec.host}{"\n"}')

oc apply -f <($ISTIO_DIR/bin/istioctl kube-inject -f $ISTIO_DIR/samples/bookinfo/kube/bookinfo.yaml)

oc expose svc productpage
```

## Deploy Using bash script
```bash
./install clean
``` 

## Access the services

- Product Page

```bash
PRODUCTPAGE=$(oc get route productpage -o jsonpath='{.spec.host}{"\n"}')
open http://$PRODUCTPAGE/productpage
```

- Service Graph
```bash
SERVICEGRAPH=$(oc get route servicegraph -o jsonpath='{.spec.host}{"\n"}')
open http://$SERVICEGRAPH/dotviz
```

- Grafana

```bash
GRAFANA=$(oc get route grafana -o jsonpath='{.spec.host}{"\n"}')/dotviz
open http://$GRAFANA/dashboard/db/istio-dashboard
```

- Zipkin
```bash
ZIPKIN=$(oc get route zipkin -o jsonpath='{.spec.host}{"\n"}')
open http://$ZIPKIN/zipkin/
```





