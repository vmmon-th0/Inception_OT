#!/bin/bash

set -e

# KUBECTL, https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

function install_kubectl {
    if command -v kubectl &> /dev/null; then
        echo "kubectl is already installed"
        kubectl version
    else
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

        # OPTIONAL
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
        echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

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

function get_argo_pass {
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > ./argo-credentials.txt
}

function init_argoCD {
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    sleep 20
}

function init_cluster {
    k3d cluster create iot-cluster
    echo "The cluster \"iot-cluster\" was successfully initialized"
}

function launch_argoCD_UI {
    echo "Waiting for kubernetes services to start..."

    local NAMESPACE="argocd"
    local ALL_READY=false

    while ! $ALL_READY; do
        local PODS=$(kubectl get pods -n $NAMESPACE --no-headers)
        local ALL_READY=true

        while IFS= read -r pod; do
            local POD_NAME=$(echo $pod | awk '{print $1}')
            local POD_STATUS=$(echo $pod | awk '{print $3}')

            if [[ -z "$POD_NAME" ]]; then
                continue
            fi

            if [[ $POD_STATUS != "Running" && $POD_STATUS != "Completed" ]]; then
                echo "The pod '$POD_NAME' in the namespace '$NAMESPACE' is not in 'Ready' state."
                ALL_READY=false
            fi
        done <<< $PODS

        if ! $ALL_READY; then
            echo "Some pods in the namespace '$NAMESPACE' are not in 'Ready' state. Wait before checking again..."
            sleep 10
        fi
    done

    kubectl port-forward -n argocd svc/argocd-server 8080:443 > port-forward.log 2>&1 &
    echo "Port forwarding has been successfully completed, the Argo CD UI is now available from your host machine"
}

function deploy_argoCD {
    kubectl apply -f /home/vmmon/Desktop/Inception_OT/p3/confs/application.yaml
}

function clean_up {
    # Delete output files
    rm -f ./port-forwarding.log
    rm -f ./argo-credentials.txt

    # Delete all ressource in all namespaces
    kubectl delete all --all --all-namespaces
    kubectl delete configmap --all --all-namespaces
    kubectl delete secret --all --all-namespaces
    kubectl delete pvc --all --all-namespaces
    kubectl delete service --all --all-namespaces
    kubectl delete ingress --all --all-namespaces
    kubectl delete deployment --all --all-namespaces
    kubectl delete statefulset --all --all-namespaces
    kubectl delete daemonset --all --all-namespaces

    # Delete cluster k3d
    k3d cluster delete --all

    echo "The total clean up was done successfully"
}

# List all ressources for user information
kubectl get all --all-namespaces
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
launch_argoCD_UI
get_argo_pass
deploy_argoCD
