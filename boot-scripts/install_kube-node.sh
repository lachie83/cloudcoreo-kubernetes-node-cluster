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

echo "installing kubernetes"

kube_dir="/opt/kubernetes"
rm -rf "$kube_dir"
mkdir -p "$kube_dir"
mkdir -p "$kube_dir/build"
(
    cd /tmp
    rm -f "kubernetes.tar.gz"
    curl -L "https://github.com/kubernetes/kubernetes/releases/download/v${KUBE_VERSION}/kubernetes.tar.gz" -o "kubernetes.tar.gz"

    rm -rf kubernetes/
    tar xzvf "kubernetes.tar.gz"

    tar xzvf kubernetes/server/kubernetes-server-linux-amd64.tar.gz -C "$kube_dir/build"
    cp $kube_dir/build/kubernetes/server/bin/* $kube_dir/
    rm -rf $kube_dir/build
)

cd "$kube_dir"
name="$(echo $MY_IPADDRESS | perl -pe 's{\.}{}g')"

nohup ./kube-proxy \
    --master=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 \
    --v=2 \
    2>&1 >> ${KUBE_PROXY_LOG_FILE} &

# Use KUBELET_OPTS to modify the start/restart options
nohup ./kubelet --address=$MY_IPADDRESS \
  --port=10250 \
  --hostname_override=$MY_IPADDRESS \
  --api_servers=http://${KUBE_MASTER_NAME}.${DNS_ZONE}:8080 \
  --v=2 \
    2>&1 >> ${KUBE_KUBLET_LOG_FILE} &
