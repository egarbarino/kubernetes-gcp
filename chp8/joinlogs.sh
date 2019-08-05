#!/bin/sh
daemons=$(kubectl get pod -l name=logd -o jsonpath --template={.items[*].metadata.name})
for i in $daemons; do kubectl exec $i -- cat /var/node_log ; done | sort -g