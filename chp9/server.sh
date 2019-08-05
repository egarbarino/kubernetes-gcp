#!/bin/sh
kubectl delete -f server.yaml --ignore-not-found=true
kubectl apply -f server.yaml