#!/bin/sh
# control.sh
./startQueue.sh
kubectl apply -f multiplier-external.yaml
n=0
replicas=0
while [ $n -ne 100 ]
do n=$(kubectl logs -l job-name=multiplier-external \
       --tail=999 | wc -l)
   replicas=$(($replicas+1))
   kubectl patch job/multiplier-external \
      -p '{"spec":{"parallelism":'$replicas'}}'   
   echo Processed numbers: $n/100 - Pods: $replicas
   sleep 0.25;
done
