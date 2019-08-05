#!/bin/bash
kubectl delete -f rebalance-down.yaml --ignore-not-found=true
kubectl apply -f rebalance-down.yaml
sleep 5
phase="Starting"
while [[ "$phase" -ne "Running" ]]
do
  phase=$(kubectl get -o jsonpath --template={.status.phase} pod/rebalance) 
  echo $phase
  sleep 1
done
kubectl logs -f pod/rebalance