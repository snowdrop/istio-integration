# Istio Deployment on OpenShift

The following [blog article](https://blog.openshift.com/evaluate-istio-openshift/) details how to install OpenShift.

## Launch OpenShift on your laptop

Remark : the version 3.7.0 of OpenShift is at least required

```bash
minishift config set memory 3GB
minishift config set cpus 2
minishift config set vm-driver xhyve
minishift addon enable admin-user
minishift config set openshift-version v3.7.1
minishift start 
eval $(minishift oc-env)
```

## Log to the OpenShift platform

```bash
eval $(minishift oc-env)
oc login -u admin -p admin
```

## Install istio distro locally
```bash
curl -L https://git.io/getLatestIstio | sh -
```

## Deploy Istio

```bash
# From istio doc
oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account
oc adm policy add-scc-to-user anyuid -z istio-egress-service-account
oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account
oc adm policy add-scc-to-user anyuid -z default

# Deployment
oc new-project istio-system
ISTIO_DIR=$(find . -name \*istio\* -type d -maxdepth 1 -print -quit)
oc create -f $ISTIO_DIR/install/kubernetes/istio.yaml

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

# Jaeger installation (instead of Zipkin)
oc apply -n istio-system -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml

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

## Distributed tracing and Jaeger
```bash
oc apply -n istio-system -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
```





