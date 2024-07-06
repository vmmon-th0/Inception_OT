cat >/etc/motd <<'EOF'
__      _____| |__        ___  ___ _ ____   _____ _ __ ___
\ \ /\ / / _ \ '_ \ _____/ __|/ _ \ '__\ \ / / _ \ '__/ __|
 \ V  V /  __/ |_) |_____\__ \  __/ |   \ V /  __/ |  \__ \
  \_/\_/ \___|_.__/      |___/\___|_|    \_/ \___|_|  |___/
EOF

echo "[k42s] firewalld disabled"
systemctl disable firewalld --now

echo "[k42s] install packages"
sudo yum upgrade
sudo yum install -y nano
sudo yum install -y net-tools

echo "[k42s] k3s installation on node"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=$MASTERNODE_IP --flannel-iface=eth1" K3S_KUBECONFIG_MODE="644" sh -s -

echo "[k42s] Workload Deployment app1"
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app1/app1.configMap.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app1/app1.deployment.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app1/app1.service.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app1/app1.ingress.yaml

echo "[k42s] Workload Deployment app2"
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app2/app2.configMap.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app2/app2.deployment.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app2/app2.service.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app2/app2.ingress.yaml

echo "[k42s] Workload Deployment app3"
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app3/app3.configMap.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app3/app3.deployment.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app3/app3.service.yaml
sudo /usr/local/bin/k3s kubectl apply -f /home/vagrant/shared/app3/app3.ingress.yaml
