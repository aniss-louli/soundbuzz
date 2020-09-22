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
    apt-transport-https -y\
    ca-certificates -y\
    curl -y\
    gnupg-agent -y\
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
#Instal Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose 
#Instal Git
sudo apt update && sudo apt install git -y
#Création Dossier
mkdir elk
mkdir grafana-prometheus
mkdir wordpress
#Instal ELK
cd elk
sudo bash -c cat << EOF > docker-compose.yml
version: '3.2'

services:
  elasticsearch:
    build:
      context: elasticsearch/
      args:
        ELK_VERSION: $ELK_VERSION
    volumes:
      - type: bind
        source: ./elasticsearch/config/elasticsearch.yml
        target: /usr/share/elasticsearch/config/elasticsearch.yml
        read_only: true
      - type: volume
        source: elasticsearch
        target: /usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
    environment:
      ES_JAVA_OPTS: "-Xmx256m -Xms256m"
      ELASTIC_PASSWORD: changeme
    networks:
      - elk

  logstash:
    build:
      context: logstash/
      args:
        ELK_VERSION: $ELK_VERSION
    volumes:
      - type: bind
        source: ./logstash/config/logstash.yml
        target: /usr/share/logstash/config/logstash.yml
        read_only: true
      - type: bind
        source: ./logstash/pipeline
        target: /usr/share/logstash/pipeline
        read_only: true
    ports:
      - "5000:5000"
      - "9600:9600"
    environment:
      LS_JAVA_OPTS: "-Xmx256m -Xms256m"
    networks:
      - elk
    depends_on:
      - elasticsearch

  kibana:
    build:
      context: kibana/
      args:
        ELK_VERSION: $ELK_VERSION
    volumes:
      - type: bind
        source: ./kibana/config/kibana.yml
        target: /usr/share/kibana/config/kibana.yml
        read_only: true
    ports:
      - "5601:5601"
    networks:
      - elk
    depends_on:
      - elasticsearch

networks:
  elk:
    driver: bridge

volumes:
  elasticsearch:
EOF
cd ..
#Instal Prometheus/Grafana
cd grafana-prometheus
sudo bash -c cat << EOF > docker-compose.yml
version: '2.1'

networks:
  monitor-net:
    driver: bridge

volumes:
    prometheus_data: {}
    grafana_data: {}

services:

  prometheus:
    image: prom/prometheus:v2.17.1
    container_name: prometheus
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    expose:
      - 9090
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  nodeexporter:
    image: prom/node-exporter:v0.18.1
    container_name: nodeexporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    expose:
      - 9100
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

  grafana:
    image: grafana/grafana:6.7.2
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_USER=${ADMIN_USER}
      - GF_SECURITY_ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: unless-stopped
    expose:
      - 3000
    networks:
      - monitor-net
    labels:
      org.label-schema.group: "monitoring"

EOF
cd ..
#Instal Wordpress
cd wordpress
sudo bash -c cat << EOF > docker-compose.yml
version: '2'

services:
   db:
     image: mysql:5.7
     volumes:
       - db_data:/var/lib/mysql
     restart: always
     environment:
       MYSQL_ROOT_PASSWORD: somewordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress

   wordpress:
     depends_on:
       - db
     image: wordpress:latest
     ports:
       - "8000:80"
     restart: always
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD: wordpress
volumes:
    db_data:
EOF
