#!/bin/sh
# wip/configmap.sh
kubectl delete configmap scripts --ignore-not-found=true
kubectl create configmap scripts --from-file=../server.py 