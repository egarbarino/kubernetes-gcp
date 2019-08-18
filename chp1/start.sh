#!/bin/sh
# start.sh
gcloud container clusters create my-cluster \
  --num-nodes=3 \
  --issue-client-certificate \
  --enable-basic-auth \
  --zone=europe-west2-a \
#  --cluster-version=1.13.7-gke.19