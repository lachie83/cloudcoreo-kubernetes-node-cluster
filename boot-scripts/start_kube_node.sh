#!/bin/bash
set -x
######################################################################
#
# VARIABLES:
#   KUBE_VERSION = 1.0.6
#   KUBE_MASTER_NAME =
#   DNS_ZONE = dev.aws.lcloud.com
#   KUBE_KUBLET_LOG_FILE = /var/log/kube-kublet.log
#   KUBE_PROXY_LOG_FILE = /var/log/kube-proxy.log
#
# PORTS:
#     kublet = 10248, 10250, 10255
#######################################################################

## this stack extends the leader elect cluster, so lets source in the cluster profile and expose some variables to us
source /etc/profile.d/cluster

kube_dir="/opt/kubernetes"
(
    cd "$kube_dir"
    name="$(echo $MY_IPADDRESS | perl -pe 's{\.}{}g')"

    nohup ./kube-proxy \
	--master=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 \
	--v=2 \
	2>&1 >> ${KUBE_PROXY_LOG_FILE} &

    # Use KUBELET_OPTS to modify the start/restart options
    nohup ./kubelet --address=$MY_IPADDRESS \
	--port=10250 \
	--hostname_override=$name \
	--api_servers=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 \
	--v=2 \
	2>&1 >> ${KUBE_KUBLET_LOG_FILE} &
)
