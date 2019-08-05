#!/bin/sh
kubectl delete -f server-disk.yaml --ignore-not-found=true
kubectl apply -f server-disk.yaml