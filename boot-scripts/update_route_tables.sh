#!/bin/bash

source /etc/profile.d/cluster
( 
    name="$(echo $MY_IPADDRESS | perl -pe 's{\.}{}g')"
    route="$(cat /etc/sysconfig/docker | grep bip | awk -F'bip=' '{print $2}' | perl -pe 's{\"}{}g')"
    python ./lib/kubernetes-node-router.py --bip "$route"
)
