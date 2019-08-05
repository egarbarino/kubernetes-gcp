#!/bin/bash
kubectl delete -f client-ro-2.yaml --ignore-not-found=true
kubectl apply -f client-ro-2.yaml
echo "Starting Client Read Only 2..."
sleep 5
phase="Launched"
while [[ "$phase" -ne "Running" ]]
do
  phase=$(kubectl get -o jsonpath --template={.status.phase} pod/client-ro-2) 
  echo $phase
  sleep 1
done
echo Done
kubectl logs -f client-ro-2