#!/bin/bash
kubectl delete -f client-ro-3.yaml --ignore-not-found=true
kubectl apply -f client-ro-3.yaml
echo "Starting Client Read Only 3..."
sleep 5
phase="Launched"
while [[ "$phase" -ne "Running" ]]
do
  phase=$(kubectl get -o jsonpath --template={.status.phase} pod/client-ro-3) 
  echo $phase
  sleep 1
done
echo Done
kubectl logs -f client-ro-3