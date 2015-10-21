#!/bin/bash

source /etc/profile.d/cluster
(
    cd /opt/kubernetes
    ./kubectl --server=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 get nodes | grep -i \\bnotready\\b | while read name label status; do
        ./kubectl --server=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 delete node $name
    done
)

