#!/bin/sh
# stop.sh
gcloud container clusters delete my-cluster --quiet --async \
  --zone=europe-west2-a 
