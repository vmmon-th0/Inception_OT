cat >/etc/motd <<'EOF'
  _    ____
 | |  |___ \
 | | __ __) |___
 | |/ /|__ </ __|        _
 |   < ___) \__ \       | |
 |_|\_\____/|___/_ _ __ | |_
  / _` |/ _` |/ _ \ '_ \| __|
 | (_| | (_| |  __/ | | | |_
  \__,_|\__, |\___|_| |_|\__|
         __/ |
        |___/
EOF

echo "[k42s] firewalld disabled"
systemctl disable firewalld --now

echo "[k42s] install packages"
yum -y install net-tools

echo "[k42s] k3s installation on node"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://$MASTERNODE_IP:6443 --token-file /home/vagrant/shared/token --node-ip=$WORKERNODE_IP --flannel-iface=eth1" K3S_KUBECONFIG_MODE="644" sh -s -
