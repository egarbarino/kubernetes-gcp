#!/bin/sh
# create.sh
gcloud container clusters create my-cluster \
  --issue-client-certificate \
  --enable-basic-auth \
  --zone=europe-west2-a