#!/bin/sh
# part1/configmap.sh
kubectl delete configmap scripts --ignore-not-found=true
kubectl create configmap scripts --from-file=../server.py 