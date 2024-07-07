cat >/etc/motd <<'EOF'
  _    ____
 | |  |___ \
 | | __ __) |___
 | |/ /|__ </ __|
 |   < ___) \__ \
 |_|\_\____/|___/   _____ _ __
 / __|/ _ \ '__\ \ / / _ \ '__|
 \__ \  __/ |   \ V /  __/ |
 |___/\___|_|    \_/ \___|_|
EOF

echo "[k42s] firewalld disabled"
systemctl disable firewalld --now

echo "[k42s] install packages"
sudo yum upgrade -y
sudo yum install -y net-tools

echo "[k42s] k3s installation on node"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=$MASTERNODE_IP --flannel-iface=eth1" K3S_KUBECONFIG_MODE="644" sh -s - --token 12345

echo "[k42s] server token are shared via synced_folder technique"
sudo cp /var/lib/rancher/k3s/server/token /home/vagrant/shared
