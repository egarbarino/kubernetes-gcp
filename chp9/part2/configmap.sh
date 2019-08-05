#!/bin/sh
# part2/configmap.sh
kubectl delete configmap scripts --ignore-not-found=true
kubectl create configmap scripts --from-file=../server.py --from-file=../client.py