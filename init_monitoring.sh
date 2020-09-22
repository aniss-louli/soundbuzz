#Fixe l'IP
sudo bash -c cat << EOF > /etc/network/interfaces
iface ens192 inet static
    address 192.168.70.4
    netmask 255.255.255.0
    gateway 192.168.70.250
EOF
#Déf des DNS
sudo bash -c cat << EOF > /etc/resolv.conf
nameserver 192.168.70.1
nameserver 192.168.70.2
EOF
#MAJ 
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl -y
#MAJ des repo
echo "deb http://deb.debian.org/debian buster main">>/etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian buster main">>/etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security/ buster/updates main">>/etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian-security/ buster/updates main">>/etc/apt/sources.list
echo "deb http://deb.debian.org/debian buster-updates main">>/etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian buster-updates main">>/etc/apt/sources.list
sudo apt update && sudo apt upgrade -y
#Instal Docker
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
#Instal Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose 
#Instal Git
sudo apt update && sudo apt install git
#Création Dossier
mkdir elk
mkdir grafana-prometheus
mkdir wordpress
#Téléchargement ELK
cd elk
git clone https://github.com/deviantony/docker-elk
cd ..
#Téléchargement Prometheus/Grafana
cd grafana-prometheus
git clone https://github.com/Einsteinish/Docker-Compose-Prometheus-and-Grafana
cd ..
#Téléchargement Wordpress
cd wordpress
git clone https://github.com/kassambara/wordpress-docker-compose
