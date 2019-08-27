#!/bin/sh
# stop.sh
gcloud container clusters delete my-cluster --async --quiet --zone=europe-west2-a
