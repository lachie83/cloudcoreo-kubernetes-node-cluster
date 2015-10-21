#!/bin/bash

yum install -y docker
pip install netaddr

source /etc/profile.d/cluster

name="$(echo $MY_IPADDRESS | perl -pe 's{\.}{}g')"
all_nets="$(python ./lib/generate_network_blocks.py  --master-cidr-block ${KUBE_NODE_IP_CIDRS} --cidr-divider ${KUBE_NODE_IP_CIDRS_SUBDIVIDER})"

## get an unused bip
(
    kube_dir="/opt/kubernetes"
    cd "$kube_dir"
    used_nets="$(./kubectl --server=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 get nodes | grep -i \\bready\\b | grep ipblock | awk -F'ipblock=' '{print $2}' | perl -pe 's#([0-9\.]+).*#\1#g')"

    DOCKER_BIP=
    for aNet in $all_nets; do
	unused=true
	for uNet in $used_nets; do
	    if [ "$uNet" = "$aNet" ]; then
		unused=false
	    fi
	done
	
	if [ $unused = true ]; then
	    DOCKER_BIP="$aNet"
	    break
	fi
    done
    
    ## docker config
    cat <<EOF > /etc/sysconfig/docker
# The max number of open files for the daemon itself, and all
# running containers.  The default value of 1048576 mirrors the value
# used by the systemd service unit.
DAEMON_MAXFILES=1048576

# Additional startup options for the Docker daemon, for example:
# OPTIONS="--ip-forward=true --iptables=true"
# By default we limit the number of open files per container
OPTIONS="--default-ulimit nofile=1024:4096 --bip=${DOCKER_BIP}/${KUBE_NODE_IP_CIDRS_SUBDIVIDER}"
EOF

)
