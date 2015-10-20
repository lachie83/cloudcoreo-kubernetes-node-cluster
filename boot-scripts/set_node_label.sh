#!/bin/bash

source /etc/profile.d/cluster
( 
    name="$(echo $MY_IPADDRESS | perl -pe 's{\.}{}g')"

    cd /opt/kubernetes
    ./kubectl --server=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 \
	label nodes "$name" \
	ipblock=1.2.3.4 \
	--overwrite
)
