#!/bin/bash
kubectl delete -f client.yaml --ignore-not-found=true
kubectl apply -f client.yaml
echo "Starting Client..."
sleep 5
phase="Launched"
while [[ "$phase" -ne "Running" ]]
do
  phase=$(kubectl get -o jsonpath --template={.status.phase} pod/client) 
  echo $phase
  sleep 1
done
echo Done
kubectl logs -f client