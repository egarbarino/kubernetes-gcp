#!/bin/sh

gcloud container clusters create my-cluster --num-nodes=3 --issue-client-certificate --enable-basic-auth 

