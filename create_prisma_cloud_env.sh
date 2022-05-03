#!/bin/bash

ACCESS_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

if ! command -v kind &> /dev/null; then
    echo "kind could not be found"
    exit
fi

if ! command -v kubectl &> /dev/null; then
    echo "kubectl could not be found"
    exit
fi

if [ ! -f prisma_cloud_compute_edition_22_01_880.tar.gz ]; then
    echo "Prisma Cloud Compute Package could not be found"
    exit
fi

PLATFORM='unknown'
case "$OSTYPE" in
  darwin*)  PLATFORM=osx ;; 
  linux*)   PLATFORM=linux ;;
  msys*)    PLATFORM=windows ;;
  *)        echo "Platorm type not supported"; exit ;;
esac

#
# Create KIND Kubernetes cluster and install Nginx ingress controller
#

kind delete cluster --name prismacloud
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: prismacloud
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=-1s

#
# Install Prisma Cloud Console
#

mkdir -p prisma_cloud
tar xvzf prisma_cloud_compute_edition_22_01_880.tar.gz -C prisma_cloud/
pushd prisma_cloud
${PLATFORM}/twistcli console export kubernetes --service-type ClusterIP --registry-token ${ACCESS_TOKEN}
kubectl create -f twistlock_console.yaml
popd

kubectl wait --namespace twistlock --for=condition=ready pod --selector=name=twistlock-console --timeout=-1s
kubectl apply -f prisma-cloud-compute-console-ingress.yaml

