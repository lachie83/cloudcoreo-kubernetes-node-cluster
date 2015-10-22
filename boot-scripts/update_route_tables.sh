#!/bin/bash

source /etc/profile.d/cluster
( 
    name="$(echo $MY_IPADDRESS | perl -pe 's{\.}{}g')"
    route="$(cat /etc/sysconfig/docker | grep dockernet | awk -F'dockernet=' '{print $2}' | perl -pe 's{\"}{}g')"
    python ./lib/kubernetes-node-router.py --bip "$route"
)
