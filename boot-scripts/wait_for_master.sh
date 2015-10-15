#!/bin/bash
set -x
######################################################################
#
# VARIABLES:
#   KUBE_MASTER_NAME =
#   DNS_ZONE = dev.aws.lcloud.com
#
#######################################################################

kube_dir="/opt/kubernetes"
(
    cd "$kube_dir"
    while ! ./kubectl --server=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 cluster-info 2>&1 | grep -q "master is running" ; do
	echo "waiting for leader";
	sleep 5
    done
    
)
