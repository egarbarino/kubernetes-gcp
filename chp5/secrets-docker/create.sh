#!/bin/sh
kubectl create secret docker-registry docker-hub-secret --docker-server=docker.io --docker-username=egarbarino --docker-password=Testing$123 --docker-email=ernesto@garba.org
