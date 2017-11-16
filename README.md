# istio-integration

## Download istio

## Configure minishift

./minishift profile set istio-demo
./minishift config set memory 3GB
./minishift config set cpus 2
./minishift config set vm-driver virtualbox
./minishift addon enable admin-user
./minishift config set openshift-version v3.7.0-rc.0

./minishift start 

oc login 
admin
admin

## Deploy

oc new-project istio-system

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

ISTIO_DIR="/Users/dabou/MyApplications/istio-0.2.12"
oc create -f $ISTIO_DIR/install/kubernetes/istio.yaml

oc expose svc istio-ingress

oc apply -f $ISTIO_DIR/install/kubernetes/addons/prometheus.yaml
oc apply -f $ISTIO_DIR/install/kubernetes/addons/grafana.yaml
oc apply -f $ISTIO_DIR/install/kubernetes/addons/servicegraph.yaml

oc expose svc servicegraph
oc expose svc grafana

oc apply -f <(bin/istioctl kube-inject -f $ISTIO_DIR/samples/bookinfo/kube/bookinfo.yaml)

oc expose svc productpage
