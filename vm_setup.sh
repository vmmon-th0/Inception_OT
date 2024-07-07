echo "[IOT] update upgrade"
sudo apt update && sudo apt upgrade

echo "[IOT] install git"
sudo apt install git

echo "[IOT] vagrant git"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant

echo "[IOT] install vb-guest plugin"
vagrant plugin install vagrant-vbguest

echo "[IOT] install virtualbox with additional dkms"
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt update
sudo apt install virtualbox-7.0
sudo usermod -G vboxusers -a $USER
sudo /etc/init.d/vboxdrv setup
sudo apt install --reinstall linux-headers-$(uname -r) virtualbox-dkms dkms

echo "[IOT] install kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "[IOT] install k3d"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
