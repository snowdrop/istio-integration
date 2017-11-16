#!/usr/bin/env bash

# Command to be executed to install istio is
# ./install.sh
# To delete istio-system namespace and resources, then pass this parameter
# ./install,sh clean

clean() {
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
}

if [ "$1"="clean" ] ; then
  oc delete project istio-system --force=true
  while oc get project istio-system -o jsonpath='{.metadata.name}' | grep -F "istio-system"; do sleep 10s && echo "wait till project is deleted"; done;
  clean
fi

echo "Create namespace"
oc new-project istio-system

echo "Define security rules"
oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account
oc adm policy add-scc-to-user privileged -z istio-ingress-service-account
oc adm policy add-scc-to-user anyuid -z istio-egress-service-account
oc adm policy add-scc-to-user privileged -z istio-egress-service-account
oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account
oc adm policy add-scc-to-user privileged -z istio-pilot-service-account
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user privileged -z default
oc adm policy add-cluster-role-to-user cluster-admin -z default

echo "Install istio"
curl -L https://git.io/getLatestIstio | sh -
ISTIO_DIR=$(find . -name \*istio\* -type d -maxdepth 1 -print -quit)

oc new-project istio-system
oc create -f $ISTIO_DIR/install/kubernetes/istio.yaml

echo "Deploy additional services"
oc create -f $ISTIO_DIR/install/kubernetes/addons/prometheus.yaml
oc create -f $ISTIO_DIR/install/kubernetes/addons/grafana.yaml
oc create -f $ISTIO_DIR/install/kubernetes/addons/servicegraph.yaml
oc create -f $ISTIO_DIR/install/kubernetes/addons/zipkin.yaml
oc expose svc servicegraph
oc expose svc grafana
oc expose svc zipkin

SERVICEGRAPH=$(oc get route servicegraph -o jsonpath='{.spec.host}{"\n"}')
GRAFANA=$(oc get route grafana -o jsonpath='{.spec.host}{"\n"}')
ZIPKIN=$(oc get route zipkin -o jsonpath='{.spec.host}{"\n"}')

echo "Install Book info example"
oc apply -f <($ISTIO_DIR/bin/istioctl kube-inject -f $ISTIO_DIR/samples/bookinfo/kube/bookinfo.yaml)
oc expose svc productpage
PRODUCTPAGE=$(oc get route productpage -o jsonpath='{.spec.host}{"\n"}')

# Open Screens
open http://$SERVICEGRAPH/dotviz
open http://$GRAFANA/dashboard/db/istio-dashboard
open http://$ZIPKIN/zipkin/
open http://$PRODUCTPAGE/productpage