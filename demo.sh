#!/bin/bash

export PATH=$PATH:/Users/burr/minishift_halloween_2017/istio/istio-0.2.10/bin

echo "istioctl -n istio-system get routerule"
istioctl -n istio-system get routerule
echo "Therefore random load-balancing across reviews v1, v2, v3"
read -s
clear

PRODUCTPAGEPOD=$(kubectl get pod -l app=productpage -o jsonpath='{.items[0].metadata.name}')

echo "Everyone Only Reviews v1"
echo "istioctl -n istio-system create -f samples/bookinfo/kube/route-rule-reviews-v1.yaml"
istioctl -n istio-system create -f samples/bookinfo/kube/route-rule-reviews-v1.yaml
echo
istioctl -n istio-system get routerule reviews-default -o yaml
# kubectl exec -it ${PRODUCTPAGEPOD} -- curl http://reviews:9080
echo "Go refresh the page"
read -s

echo "Everyone Only Reviews v2"
echo "istioctl -n istio-system replace create -f samples/bookinfo/kube/route-rule-reviews-v2.yaml"
istioctl -n istio-system replace -f samples/bookinfo/kube/route-rule-reviews-v2.yaml
echo
istioctl -n istio-system get routerule reviews-default -o yaml
# kubectl exec -it ${PRODUCTPAGEPOD} -- curl http://reviews:9080
echo "Go refresh the page"
read -s

echo "Everyone Only Reviews v3"
echo "istioctl -n istio-system replace create -f samples/bookinfo/kube/route-rule-reviews-v3.yaml"
istioctl -n istio-system replace -f samples/bookinfo/kube/route-rule-reviews-v3.yaml
echo
istioctl -n istio-system get routerule reviews-default -o yaml
# kubectl exec -it ${PRODUCTPAGEPOD} -- curl http://reviews:9080
echo "Go refresh the page"
read -s

echo "Everyone Back Reviews v1"
echo "istioctl -n istio-system replace -f samples/bookinfo/kube/route-rule-reviews-v1.yaml"
istioctl -n istio-system replace -f samples/bookinfo/kube/route-rule-reviews-v1.yaml
echo
istioctl -n istio-system get routerule reviews-default -o yaml
# kubectl exec -it ${PRODUCTPAGEPOD} -- curl http://reviews:9080
echo "Go refresh the page"
read -s

echo "Burr to Reviews v3"
echo "istioctl -n istio-system create -f samples/bookinfo/kube/route-rule-reviews-burr-v3.yaml"
istioctl -n istio-system create -f samples/bookinfo/kube/route-rule-reviews-burr-v3.yaml
echo
istioctl -n istio-system get routerule reviews-burr-v3 -o yaml
echo "Go login as Burr"
read -s

clear

echo "Inject a fault - ratings delay for Burr"
echo "istioctl -n istio-system create -f samples/bookinfo/kube/route-rule-ratings-burr-delay.yaml"
istioctl -n istio-system create -f samples/bookinfo/kube/route-rule-ratings-burr-delay.yaml
echo
istioctl -n istio-system get routerule ratings-burr-delay -o yaml
echo "Go refresh the page while logged in as Burr"
read -s

clear


echo "Ready to Clean Up?"
read -s

echo "istioctl -n istio-system delete routerule ratings-burr-delay"
istioctl -n istio-system delete routerule ratings-burr-delay

echo "istioctl -n istio-system delete routerule reviews-burr-v3"
istioctl -n istio-system delete routerule reviews-burr-v3

echo "istioctl -n istio-system delete routerule reviews-default"
istioctl -n istio-system delete routerule reviews-default

echo "THE END"
demo.sh