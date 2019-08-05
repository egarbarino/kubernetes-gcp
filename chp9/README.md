---
title: StatefulSet Code Examples
date: 2018-09-09
author: Ernesto Garbarino
---

StatefulSet Code Examples
=========================

The files in this folder help demonstrate the writing of a scalable key/value store backing service using the Kubernetes StatefulSet controller.

The files are organised as follows:

* Python Script ConfigMap
    * [configmap.sh](configmap.sh) - Upload python scripts as a ConfigMap
* Server Application
    * [server.py](server.py)     - The key/value store. 
    * [server.yaml](server.yaml) - Run a 3 replica store with RAM storage
    * [server.sh](server.sh)     - Launch script for server.yaml
    * [server-disk.yaml](server-disk.yaml) - Run a 3 replica store with Persistent storage
    * [server-disk.sh](server-disk.yaml) - Launch script for server-disk.yaml 
* Client Application
    * [client.py](client.py)     - A sample key/value store client 
    * [client.yaml](client.yaml) - Run a sample read/write client against the 3 replica store 
    * [client.sh](client.sh)     - Launch script for client.yaml
    * [client-ro-2.yaml](client-ro-2.yaml) - Read only client for 2 replicas
    * [client-ro-2.sh](client-ro-2.sh) - Launch script for client-ro-2.yaml
    * [client-ro-3.yaml](client-ro-3.yaml) - Read only client for 3 replicas
    * [client-ro-3.sh](client-ro-3.sh) - Launch script for client-ro-3.yaml
* Rebalance Cluster
    * [rebalance.py](rebalance.py) - Migrate key/values when scaling up or down 
    * [rebalance-down.yaml](rebalance-down.yaml) - Migrate keys from a 3 replica server to 2 replica server 
    * [rebalance-down.sh](rebalance-down.sh) - Launch script for rebalance-down.yaml
    * [rebalance-up.yaml](rebalance-up.yaml) - Migrate keys from a 2 replica server to 3 replica server 
    * [rebalance-up.sh](rebalance-up.sh) - Launch script for rebalance-up.yaml


## Local Use Without Kubernetes

### Requirements 

* A Unix-like environment such as Linux, Windows Subsystem for Linux (WLS), etc.
* Python 3
* The [Flask](http://flask.pocoo.org/) framework. E.g. `pip3 install flask`
* Root/sudo access if running the server on ports up to 1024 
* Use of [TMUX](https://en.wikipedia.org/wiki/Tmux) or a terminal with tabs

For the steps the term "panel" will normally refer to a TMUX panel but it may
be understood as a separate terminal or a separate tab. Whichever the case might be, it is convenient to have all concurrent processes visible at a glance. 

### Server and Client Running plus Server Failures 

The steps presented here show the running of the 3 replica server and its sample client under normal operation and the effect of various server failures.

Before you begin, set up the panel arrangement in advance by allocating 6 panels which will be used as follows: 

* Panels 1-3 for running the standard 3 server replicas
* Panel 4 for running the 3 server read/write client
* Panel 5 for running the 2 replica read only client
* Panel 6 for running a rebalance script   

Start the server allocating different port numbers and storage directories for each one:

```
rm -f /tmp/0/* ; ./server.py 1080 /tmp/0 # on panel 1
rm -f /tmp/1/* ; ./server.py 1081 /tmp/1 # on panel 2
rm -f /tmp/2/* ; ./server.py 1082 /tmp/2 # on panel 3
```

Start the default read/write client:

```
./client.py localhost:1080,localhost:1081,localhost:1082 # on panel 4
```

See the effects on panel 5 of destabilising the server cluster:

1. Stop one of the servers (e.g CTRL+C) and run it again later using the suggested command above. 
2. Stop one of the servers (e.g CTRL+C) and run it again later skipping the data directory deletion command, i.e. `rm -f /tmp/0` 
2. Delete one of the data directories. E.g. `rm -f /tmp/0/*`
3. Delete one of the keys (e.g. `rm /tmp/0/c`)
4. Get one of the servers into _shutting down_ status by creating a file called `_shutting_down_` in one of the data directories. E.g. `touch /tmp/2/_shutting_down_`. Remove the file afterwards. E.g. `rm -f /tmp/2/_shutting_down_`

### Scaling Down From 3 to 2 Replicas 

The purpose here is to demonstrate the process of reducing the cluster down to 2 replicas from 3.

Start a new read only client targeting only the first to servers on a different panel:

```
./client.py localhost:1080,localhost:1081 readonly # on panel 5
```

Appreciate that many letters result in cache misses. Now run the rebalance script to copy the key/values from a cluster of 3 to a cluster of 2:  

```
./rebalance.py localhost:1080,localhost:1081,localhost:1082 localhost:1080,localhost: 1081 # on panel 6  
```

Observe the client on panel 5 now showing full hits. 

Stop the server running on localhost:1082 on panel 3 now.  

## Kubernetes Demo 

### Requirements 

* A Unix-like environment such as Linux, Windows Subsystem for Linux (WLS), etc.
* Google Cloud Platform running Kubernetes v1.10
* kubectl configured and pointing to a blank 2-node+ Kubernetes cluster
* Use of [TMUX](https://en.wikipedia.org/wiki/Tmux) or a terminal with tabs

For the steps the term "panel" will normally refer to a TMUX panel but it may
be understood as a separate terminal or a separate tab. Whichever the case might be, it is convenient to have all concurrent processes visible at a glance. 

### Deploying and Testing The Key/Value Store 

For this demo, five panels are convenient: 

* Panel 1 to run `watch -n 1 kubectl get nodes`
* Panel 2,3,4 to follow the server logs 
* Panel 4 to run the client

First set up the configmap with the scripts and launch the server:

```
./configmap.sh
./server.sh
```

Watch panel 1 until all three pods are _Running_. Follow the logs on panel 2 for server 0:

```
kubectl logs -f server-0
```

Now, on panel 5 try saving and loading a few keys:

```
kubectl run test --image=busybox --rm --restart=Never -ti sh
wget -q http://server-0.server/save/title/Sapiens -O - ; echo
wget -q http://server-0.server/save/author/Yuval -O - ; echo
wget -q http://server-0.server/allKeys -O - ; echo
wget -q http://server-0.server/load/author -O - ; echo
wget -q http://server-0.server/load/title -O - ; echo
```

Restart the server again to clear the saved keys and values:

```
./server.sh
```



### Showing The Effect of Server Failures and Rebalancing

Allocate three new panels C1, C2, and C3 for running the client pods:

* Panel C1 will be used to run the default read/write client for 3 replicas
* Panel C2 will be used to run the read only client for 2 replicas
* Panel C3 will be used to run the read only client for 3 replicas

Launch the default client on panel C1:

```
./client.sh
```

Watch the effect of knocking off server-1 until it recovers:

```
kubectl delete pod/server-1
```

Start the read only client for 2 replicas on panel C2 and notice that there are key misses:

```
./client-ro-2.sh
```

Stop the read/write client running on C1 (not via CTRL+C):

```
kubectl delete pod/client 
```

Rebalance the cluster to that keys are rehashed and copied to the 2 replica cluster and watch how misses turn into hits on panel C2:

```
./rebalance-down.sh
```

Now it is safe to scale the replica set to two replicas:

```
kubectl scale statefulset/server --replicas=2
```

Let us now scale the key/value store cluster back to three replicas. Start the read only client for 3 replicas on panel C3 and note the dot meaning that the server is inaccessible:

```
./client-ro-3.sh
```

Scale now the cluster to 3 replicas and note how the dot (.) turns into a miss (m) on panel C3.

```
kubectl scale statefulset/server --replicas=3
```

Now rebalance the key/value store from 2 replicas to 3 and notice how the misses turn into hits on panel C3:

```
./rebalance-up.sh
```

You can now stop the client running on C2 (not through CTRL+C):

```
kubectl delete pod/client-ro-2
```

### Key/Value Store Running on Persistent Disk

Delete all running Kubernetes objects and apply the configmap again:

```
kubectl delete all --all
./configmap.sh
```

Check that there are no Persistent Volume Claims:

```
kubectl get pvc
```

Start the default read/write client on panel C2:

```
./client.sh
```

Start the persistent server:

```
./server-disk.sh
```

Watch as dots (.) turn into writes (w) and then hits (h) on panel C1. When all three servers are running, check the status of persistent volume claims again:

```
kubectl get pvc
```

Scale the server down to 1 replica and observe the 50x errors (5) and then dots (.) on panel C1:

```
kubectl scale statefulset/server --replicas=1
```

Scale the server back to 3 replicas and notice that no writes (w) are incurred on C1:

```
kubectl scale statefulset/server --replicas=3
```

Delete the server StatefulSet and restart it again and notice that no writes (w) are incurred either:

```
kubectl delete statefulset/server
./server-disk.sh
```

## Disclaimer

The examples serve solely a didactic purpose. The key/value store, in particular, lacks validation, exception handling, and it exposes access to the file system which may result in a severe security vulnerability even under a mere development or testing setting.

