#!/bin/bash

ACCESS_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

if ! command -v k3d &> /dev/null; then
    echo "k3d could not be found"
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
# Create K3d Kubernetes cluster and install Nginx ingress controller
#

k3d cluster delete prismacloud
k3d cluster create prismacloud --wait --k3s-arg "--no-deploy=traefik@server:*" --port 80:80@loadbalancer --port 443:443@loadbalancer --volume "$(pwd)/helm-install-ingress-nginx.yaml:/var/lib/rancher/k3s/server/manifests/helm-install-ingress-nginx.yaml"

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

