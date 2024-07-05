# REQUIREMENTS
# KUBECTL, https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#
# # OPTIONAL
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
#
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#
# kubectl version --client

# DOCKER, https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

# for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
#
# # Add Docker's official GPG key:
# sudo apt-get update
# sudo apt-get install ca-certificates curl
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc
#
# # Add the repository to Apt sources:
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
#
# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

clean_up()
{
    kubectl delete namespace dev
    kubectl delete namespace argocd
    k3d cluster delete mycluster
}

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

clean_up()

k3d cluster create mycluster

kubectl create namespace dev
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f /home/vmmon/Desktop/Inception_OT/p3/argocd/deployment.yaml
