#Fixe l'IP
sudo bash -c cat << EOF > /etc/network/interfaces
iface ens192 inet static
    address 192.168.70.3
    netmask 255.255.255.0
    gateway 192.168.70.250
EOF
#Déf des DNS
sudo bash -c cat << EOF > /etc/resolv.conf
nameserver 192.168.70.1
nameserver 192.168.70.2
EOF
#MAJ 
sudo apt install -y && sudo apt upgrade -y
sudo apt install curl -y
#MAJ des repo
echo "deb http://deb.debian.org/debian buster main">>/etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian buster main">>/etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security/ buster/updates main">>/etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian-security/ buster/updates main">>/etc/apt/sources.list
echo "deb http://deb.debian.org/debian buster-updates main">>/etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian buster-updates main">>/etc/apt/sources.list
sudo apt install -y && sudo apt upgrade -y
#Instal vmwaretools
sudo apt install open-vm-tools -y
sudo apt install open-vm-tools-desktop -y
#Instal visual studio
sudo apt install software-properties-common apt-transport-https -y
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update -y
sudo apt install code
#Instal ansible
sudo apt install ansible -y
#Instal virtualbox
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt install software-properties-common -y
sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
sudo apt update -y && sudo apt install virtualbox-6.0 -y
#Instal vagrant
curl -O https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.deb
sudo apt install ./vagrant_2.2.10_x86_64.deb -y
sudo apt-get install rsync -y
