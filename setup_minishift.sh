#!/usr/bin/env bash

minishift config set memory 3GB
minishift config set cpus 2
minishift config set vm-driver xhyve
minishift addon enable admin-user
minishift config set openshift-version v3.7.0-rc.0
minishift start
eval $(minishift oc-env)
eval $(minishift oc-env)

oc login -u admin -p admin