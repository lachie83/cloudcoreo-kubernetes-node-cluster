kubernetes-master-cluster
=========================

This repository is the [CloudCoreo](https://www.cloudcoreo.com) stack for kubernetes node clusters.

## Description
This stack will add a scalable, highly availabe, self healing kubernetes node cluster based on the [CloudCoreo leader election cluster here](http://hub.cloudcoreo.com/stack/leader-elect-cluster_35519).

Kubernetes allows you to manage a cluster of Linux containers as a single system to accelerate Dev and simplify Ops. The architecture is such that master and node clusters are both required. This is only the cluster for the nodes and expects a master cluster available [here](http://hub.cloudcoreo.com/stack/cloudcoreo-kubernetes-master-cluster_39a3c).

The node cluster is quite interesting in the way it works with the master cluster. There is a bit of work necessary in order to get routing working. Each node must have its own route entry in the route tables for the VPC in which it is containted. As a user of this cluster, you must specify the master service cidr, but you must ALSO specify the cidr block size which will be used to subdivide the master range amongst the nodes.

For instance:

Lets assume you set the `KUBE_MASTER_SERVICE_IP_CIDRS` variable to `10.234.0.0/20`. 
Your job is to decide how many (maximum) containers you want to run simultaneously on each node. 
For this, lets decide on `62` as the maximum. Great! That just happens to mean you put in a value for `KUBE_MASTER_SERVICE_IP_CIDRS_SUBDIVIDER` that gets you 64 addresses (62 usable, 1 for the broadcast and one for network address). That value is `26`.

```
KUBE_MASTER_SERVICE_IP_CIDRS = 10.234.0.0/20
KUBE_MASTER_SERVICE_IP_CIDRS_SUBDIVIDER = 25
```

So what happens now?

As nodes come up they create a table of usable values based on the two variables above. In our case there are 32 possible cidrs:
```
10.234.0.0/26
10.234.0.64/26
10.234.1.0/26
10.234.1.64/26
10.234.2.0/26
10.234.2.64/26
...
...
10.234.13.0/26
10.234.13.64/26
10.234.14.0/26
10.234.14.64/26
10.234.15.0/26
10.234.15.64/26
```
Each node will check the kubernets nodes via kubectl command and find an unused network block. It will then insert a 'blackhole' into the proper routing tables, thus allowing the master to take them over. The 'used network blocks' are determined by the labels set on the nodes.

## REQUIRED VARIABLES

### `DNS_ZONE`:
  * description: the dns zone (eg. example.com)

### `VPC_NAME`:
  * description: the cloudcoreo defined vpc to add this cluster to

### `VPC_CIDR`:
  * description: the cloudcoreo defined vpc to add this cluster to

### `PRIVATE_SUBNET_NAME`:
  * description: the private subnet in which the cluster should be added

### `PRIVATE_ROUTE_NAME`:
  * description: the private subnet in which the cluster should be added

### `KUBE_NODE_KEY`:
  * description: the ssh key to associate with the instance(s) - blank will disable ssh

## OVERRIDE OPTIONAL VARIABLES

### `KUBE_VERSION`:
  * description: kubernetes version
  * default: 1.0.6

### `KUBE_MASTER_SERVICE_IP_CIDRS`:
  * default: 10.1.1.0/24
  * description: kubernetes service cidrs

### `KUBE_MASTER_SERVICE_IP_CIDRS_SUBDIVIDER`:
  * default: 26
  * description: 

### `KUBE_ALLOW_PRIVILEGED`:
  * default: true
  * description: allow privileged containers

### `KUBE_KUBLET_LOG_FILE`:
  * description: kublet log file
  * default: /var/log/kube-kublet.log

### `KUBE_PROXY_LOG_FILE`:
  * description: ha-nat log file
  * default: /var/log/kube-api.log

### `KUBE_MASTER_NAME`:
  * default: kube-master
  * description: the name of the cluster - this will become your dns record too

### `KUBE_NODE_NAME`:
  * default: kube-node
  * description: the name of the cluster - this will become your dns record too

### `KUBE_NODE_ELB_TRAFFIC_PORTS`:
  * default: 8080
  * description: ports that need to allow traffic into the ELB

### `KUBE_NODE_ELB_TRAFFIC_CIDRS`:
  * default: 
  * description: leave this blank - we are using ELB for health checks only

### `KUBE_NODE_TCP_HEALTH_CHECK_PORT`:
  * default: 10250
  * description: a tcp port the ELB will check every so often - this defines health and ASG termination

### `KUBE_NODE_INSTANCE_TRAFFIC_PORTS`:
  * default: 1..65535
  * description: ports to allow traffic on directly to the instances

### `KUBE_NODE_INSTANCE_TRAFFIC_CIDRS`:
  * default: 10.0.0.0/8
  * description: cidrs that are allowed to access the instances directly

### `KUBE_NODE_SIZE`:
  * default: t2.small
  * description: the image size to launch

### `KUBE_NODE_GROUP_SIZE_MIN`:
  * default: 3
  * description: the minimum number of instances to launch

### `KUBE_NODE_GROUP_SIZE_MAX`:
  * default: 6
  * description: the maxmium number of instances to launch

### `KUBE_NODE_HEALTH_CHECK_GRACE_PERIOD`:
  * default: 600
  * description: the time in seconds to allow for instance to boot before checking health

### `KUBE_NODE_UPGRADE_COOLDOWN`:
  * default: 300
  * description: the time in seconds between rolling instances during an upgrade

### `TIMEZONE`:
  * default: America/LosAngeles
  * description: the timezone the servers should come up in

### `KUBE_MASTER_ELB_LISTENERS`:
  * default: [{ :elb_protocol => 'tcp', :elb_port => 10250, :to_protocol => 'tcp', :to_port => 10250 }]
  * description: The listeners to apply to the ELB

### `DATADOG_KEY`:
  * default: ''
  * description: "If you have a datadog key, enter it here and we will install the agent"

### `WAIT_FOR_KUBE_MASTER_MIN`:
  * default: true
  * description: true if the cluster should wait for all instances to be in a running state


## Tags
1. Container Management
1. Google
1. Kubernetes
1. High Availability
1. Master
1. Cluster

## Diagram
![alt text](https://raw.githubusercontent.com/lachie83/cloudcoreo-kubernetes-node-cluster/master/images/kubernetes-node-diagram.png "Kubernetes Master Cluster Diagram")

## Icon
![alt text](https://raw.githubusercontent.com/lachie83/cloudcoreo-kubernetes-node-cluster/master/images/kubernetes-node.png "kubernetes icon")

