#!/bin/bash

source /etc/profile.d/cluster
( 
    name="$(echo $MY_IPADDRESS | perl -pe 's{\.}{}g')"

    bip="$(cat /etc/sysconfig/docker | grep dockernet | awk -F'dockernet=' '{print $2}' | awk -F'/' '{print $1}')"
    cd /opt/kubernetes
    ./kubectl --server=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 \
	label nodes "$name" \
	ipblock="$bip" \
	--overwrite
)
