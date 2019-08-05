#!/bin/sh
kubectl delete --ignore-not-found pod/queue service/queue
kubectl run queue --image=alpine \
  --restart=Never \
  --port=1080 \
  --expose \
  -- sh -c \
    "i=1;while true;do echo -n \$i \
    | nc -l -p 1080; i=\$((\$i+1));done"
