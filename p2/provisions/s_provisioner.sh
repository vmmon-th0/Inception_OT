cat >/etc/motd <<'EOF'
__      _____| |__        ___  ___ _ ____   _____ _ __ ___
\ \ /\ / / _ \ '_ \ _____/ __|/ _ \ '__\ \ / / _ \ '__/ __|
 \ V  V /  __/ |_) |_____\__ \  __/ |   \ V /  __/ |  \__ \
  \_/\_/ \___|_.__/      |___/\___|_|    \_/ \___|_|  |___/
EOF

echo "[k42s] firewalld disabled"
systemctl disable firewalld --now

echo "[k42s] install packages"
yum install -y nano
yum install -y net-tools

echo "[k42s] k3s installation on node"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=$MASTERNODE_IP --flannel-iface=eth1" K3S_KUBECONFIG_MODE="644" sh -s -

echo "[k42s] Workload Deployment app1"
# kubectl apply -f /home/vagrant/shared/app1.deployment.yaml
# kubectl apply -f /home/vagrant/shared/app1.service.yaml
# kubectl apply -f /home/vagrant/shared/app1.ingress.yaml

echo "[k42s] Workload Deployment app2"
# kubectl apply -f /home/vagrant/shared/app1.deployment.yaml
# kubectl apply -f /home/vagrant/shared/app1.service.yaml
# kubectl apply -f /home/vagrant/shared/app1.ingress.yaml

echo "[k42s] Workload Deployment app3"
# kubectl apply -f /home/vagrant/shared/app1.deployment.yaml
# kubectl apply -f /home/vagrant/shared/app1.service.yaml
# kubectl apply -f /home/vagrant/shared/app1.ingress.yaml
