#!/bin/sh
# stop.sh
gcloud config set compute/zone europe-west2-a
gcloud container clusters delete my-cluster --async --quiet
