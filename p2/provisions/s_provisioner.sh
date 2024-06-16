cat >/etc/motd <<'EOF'
__      _____| |__        ___  ___ _ ____   _____ _ __ ___
\ \ /\ / / _ \ '_ \ _____/ __|/ _ \ '__\ \ / / _ \ '__/ __|
 \ V  V /  __/ |_) |_____\__ \  __/ |   \ V /  __/ |  \__ \
  \_/\_/ \___|_.__/      |___/\___|_|    \_/ \___|_|  |___/
EOF

echo "[k42s] firewalld disabled"
systemctl disable firewalld --now

echo "[k42s] install packages"
yum install -y net-tools
yum install -y nano

echo "[k42s] manifest file management"
mkdir -p /var/lib/rancher/k3s/server/manifests/

echo "[k42s] k3s installation on node"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=$MASTERNODE_IP --flannel-iface=eth1" K3S_KUBECONFIG_MODE="644" sh -s - --token 12345
