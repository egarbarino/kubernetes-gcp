#!/bin/sh
# misc/create_on_v13.sh

# Fetch the latest build of the 1.13 release
version=$(gcloud container get-server-config --zone=europe-west2-a | grep 1.13 | head -n 1 | awk '{ print $2 }')
echo Release: $version
gcloud container clusters create my-cluster \
  --issue-client-certificate \
  --enable-basic-auth \
  --cluster-version=$version \
  --zone=europe-west2-a