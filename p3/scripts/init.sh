#!/bin/bash

set -e

# KUBECTL, https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
function install_kubectl {
    if command -v kubectl &> /dev/null; then
        echo "kubectl is already installed"
        kubectl version --client
    else
        curl -Lo /tmp/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
        kubectl version --client
    fi
}

# DOCKER, https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
function install_docker {
    if command -v docker &> /dev/null; then
        echo "Docker is already installed"
        docker --version
    else
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        sudo addgroup --system docker
        sudo adduser $USER docker
        newgrp docker
        sudo setfacl -m "g:docker:rw" /var/run/docker.sock
    fi
}

function install_k3d {
    if command -v k3d &> /dev/null; then
        echo "k3d is installed. Version info:"
        k3d version
    else
        echo "k3d is not installed."
        curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    fi
}

function init_cluster {
    local CLUSTER_NAME="iot-cluster"
    k3d cluster create $CLUSTER_NAME --port 8081:30080@loadbalancer
    kubectl config use-context k3d-$CLUSTER_NAME
    echo "The cluster '$CLUSTER_NAME' was successfully initialized and set to kubectl context"
}

function init_argoCD {
    local NAMESPACE="argocd"

    kubectl create namespace $NAMESPACE
    kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    sleep 20
    kubectl wait --for=condition=ready pod --all --namespace=$NAMESPACE --timeout=600s

    if [ $? -eq 0 ]; then
        kubectl apply -f ../confs/application.yaml
        echo "ArgoCD was successfully deployed."
        kubectl port-forward -n $NAMESPACE svc/argocd-server 8080:443 > /tmp/argocd-port-forwarding.log 2>&1 &
        echo "Port forwarding has been successfully completed, the Argo CD UI is now available from your host machine"
        kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /tmp/argo-credentials.txt
        echo "Output location of ArgoCD initial admin secret: ./argo-credentials.txt"
    else
        echo "Timeout ! Some pods in the namespace $NAMESPACE are not ready. Please check the pod status."
    fi
}

function clean_up {

    # Delete all ressource in all namespaces
    kubectl delete all --all --all-namespaces
    kubectl delete configmap --all --all-namespaces
    kubectl delete secret --all --all-namespaces
    kubectl delete pvc --all --all-namespaces
    kubectl delete ingress --all --all-namespaces

    # Delete cluster k3d
    k3d cluster delete --all

    echo "The total clean up was done successfully"
}

read -p "Do you want to run the clean_up function ? (y/n): " user_input

if [[ $user_input == "y" || $user_input == "Y" ]]; then
  clean_up
else
  echo "clean up was not executed."
fi

install_kubectl
install_docker
install_k3d
init_cluster
init_argoCD
