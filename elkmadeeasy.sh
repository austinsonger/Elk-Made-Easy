#!/bin/bash
#
# OS: Debian-base Systems
#
###################################################

echo "--------------------------------------------------------------------------" 
echo " $(date)"
echo " Starting ELK+ Made Easy "
echo " ELK Stack for Debian-based Systems"
echo " Elasticsearch - Logstash - Kibana - Metricbeat - Packetbeat - Auditbeat"
echo "-------------------------------------------------------------------------"
echo " ELK+ Made Easy Status "
echo ""
echo " System Update... "

# Checking whether user has enough permission to run this script
sudo -n true
sudo apt-get update 
sudo apt-get upgrade -y
sudo apt-get install openjdk-8-jre-headless -y
sudo echo $JAVA_HOME
sudo apt-get install curl apt-transport-https software-properties-common lsb-release gnupg2 dirmngr sudo expect net-tools -y
curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list



##################################################################################################
# Install ElasticSearch, Logstash, Kibana, Metricbeat, Packetbeat, and Auditbeat on Debian/Ubuntu
##################################################################################################


##########################################
# Install Elasticsearch
##########################################
echo "$(tput setaf 1) ---- Installing the Elasticsearch Debian Package ----"
# sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.0.deb
# sudo dpkg -i /opt/elasticsearch-7.5.0.deb
apt-get update
apt-get install elasticsearch=7.5.0
sed -i "s/^#network\.host/network.host/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/^#http\.port/http.port/" /etc/elasticsearch/elasticsearch.yml
sed -i 's/^#node\.name: node\-1/node\.name: node\-1/'i /etc/elasticsearch/elasticsearch.yml
sed -i 's/^#cluster\.initial_master_nodes: \["node-1", "node-2"]/cluster.initial_master_nodes: ["node-1"]'/i /etc/elasticsearch/elasticsearch.yml
echo "$(tput setaf 1) ---- Starting Elasticsearch ----"
systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch
systemctl restart elasticsearch
echo RESTARTING Elasticsearch.......
sleep 120

#####################
# Install kibana
#####################
echo "$(tput setaf 1) ---- Installing the Kibana Debian Package ----"
# sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-7.5.0-amd64.deb
# sudo dpkg -i /opt/kibana-7.5.0-amd64.deb
apt-get install kibana=7.5.0
cp /etc/kibana/kibana.yml /tmp/
my_ip=\""$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')\""
sed -i "s/^#server\.host: \"localhost\"/server\.host: $my_ip/" /etc/kibana/kibana.yml
sed -i "s/^#server\.port/server.port/" /etc/elasticsearch/elasticsearch.yml
my_ip="$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}'):9200"
sed -i "s/^#elasticsearch\.hosts/elasticsearch.hosts/" /etc/kibana/kibana.yml
sed -i "s/^#elasticsearch\.url/elasticsearch.url/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/localhost:9200/$my_ip/" /etc/kibana/kibana.yml
echo "$(tput setaf 1) ---- Starting Kibana ----"
systemctl enable kibana
systemctl start kibana
systemctl restart kibana
echo Restarting Kibana.......
sleep 10


#####################
# Install Filebeat
#####################
echo "$(tput setaf 1) ---- Installing Filebeat ----"
# curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.0-amd64.deb
# sudo dpkg -i filebeat-7.5.0-amd64.deb
# sudo rm filebeat*
apt-get update
apt-get install filebeat==7.5.0
cp /etc/filebeat/filebeat.yml /tmp/
my_ip="$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}'):9200"
sed -i "s/YOUR_ELASTIC_SERVER_IP:9200/$my_ip/" /etc/filebeat/filebeat.yml
echo "$(tput setaf 1) ---- Starting Filebeat ----"
systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat
systemctl restart filebeat

##########################################
# Install Logstash
##########################################
echo "$(tput setaf 1) ---- Installing Logstash ----"
# sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-7.5.0.deb
# sudo dpkg -i /opt/logstash-7.5.0.deb
apt-get update
apt-get install logstash=7.5.0
echo "$(tput setaf 1) ---- Starting Logstash ----"
sudo systemctl enable logstash
sudo systemctl start logstash
sudo systemctl restart logstash

#####################
# Install Metricbeat
#####################
echo "$(tput setaf 1) ---- Installing Metricbeat ----"
#curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.5.0-amd64.deb
#sudo dpkg -i metricbeat-7.5.0-amd64.deb
#sudo rm metricbeat*
apt-get update
apt-get install metricbeat=7.5.0
echo "$(tput setaf 1) ---- Starting Metricbeat ----"
sudo systemctl enable  metricbeat
sudo systemctl start metricbeat
sudo systemctl restart metricbeat

#####################
# Install Packetbeat
#####################
echo "$(tput setaf 1) ---- Installing Packetbeat ----"
# sudo apt-get install libpcap0.8
# curl -L -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.5.0-amd64.deb
# sudo dpkg -i packetbeat-7.5.0-amd64.deb
# sudo rm packetbeat*
apt-get update
apt-get install packetbeat=7.5.0
echo "$(tput setaf 1) ---- Starting Packetbeat ----"
sudo systemctl enable packetbeat
sudo systemctl start packetbeat
sudo systemctl restart packetbeat

#####################
# Install Auditbeat
#####################
echo "$(tput setaf 1) ---- Installing Auditbeat ----"
# curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.5.0-amd64.deb
# sudo dpkg -i auditbeat-7.5.0-amd64.deb
# sudo rm auditbeat*
apt-get update
apt-get auditbeat=7.5.0
echo "$(tput setaf 1) ---- Starting Auditbeat ----"
sudo systemctl enable auditbeat
sudo systemctl start auditbeat
sudo systemctl restart auditbeat


###################
# Prevent Updates
###################
sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/elastic-7.x.list
apt-get update

######################################
# Protect Kibana with a reverse proxy
######################################

echo "$(tput setaf 1) ---- Installing and Configuring Reverse Proxy ----"
apt install nginx -y
mkdir -p /etc/ssl/certs /etc/ssl/private
cp <ssl_pem> /etc/ssl/certs/kibana-access.pem
cp <ssl_key> /etc/ssl/private/kibana-access.key
mkdir -p /etc/ssl/certs /etc/ssl/private
openssl req -x509 -batch -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/kibana-access.key -out /etc/ssl/certs/kibana-access.pem
cat > /etc/nginx/sites-available/default <<\EOF
server {
    listen 80;
    listen [::]:80;
    return 301 https://$host$request_uri;
}
server {
    listen 443 default_server;
    listen            [::]:443;
    ssl on;
    ssl_certificate /etc/ssl/certs/kibana-access.pem;
    ssl_certificate_key /etc/ssl/private/kibana-access.key;
    access_log            /var/log/nginx/nginx.access.log;
    error_log            /var/log/nginx/nginx.error.log;
    location / {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/conf.d/kibana.htpasswd;
        proxy_pass http://localhost:5601/;
    }
}
EOF
cp /etc/nginx/sites-available/default /tmp/
my_ip="$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}'):5601"
sed -i "s/localhost:5601/$my_ip/" /etc/nginx/sites-available/default
apt install apache2-utils -y
clear
echo -e "You need to set a username and password to login."
read -p "Please enter a username : " user
htpasswd -c /etc/nginx/conf.d/kibana.htpasswd $user
systemctl restart nginx
systemctl restart elasticsearch kibana



