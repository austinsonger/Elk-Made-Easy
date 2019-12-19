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
sudo apt-get upgrade
sudo apt-get install openjdk-8-jre-headless -y
sudo apt-get install curl apt-transport-https software-properties-common lsb-release gnupg2 dirmngr sudo expect net-tools -y

##################################################################################################
# Install ElasticSearch, Logstash, Kibana, Metricbeat, Packetbeat, and Auditbeat on Debian/Ubuntu
##################################################################################################

##########################################
# Install Logstash
##########################################
echo "$(tput setaf 1) ---- Installing Logstash ----"
sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-7.5.0.deb
sudo dpkg -i /opt/logstash-7.5.0.deb

echo "$(tput setaf 1) ---- Starting Logstash ----"
sudo systemctl restart logstash
sudo systemctl enable logstash   
##########################################
# Install Elasticsearch
##########################################
echo "$(tput setaf 1) ---- Installing the Elasticsearch Debian Package ----"
sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.0.deb
sudo dpkg -i /opt/elasticsearch-7.5.0.deb
echo "$(tput setaf 1) ---- Starting Elasticsearch ----"
sudo systemctl restart elasticsearch
sudo systemctl enable elasticsearch
#####################
# Install kibana
#####################
echo "$(tput setaf 1) ---- Installing the Kibana Debian Package ----"
sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-7.5.0-amd64.deb
sudo dpkg -i /opt/kibana-7.5.0-amd64.deb
echo "$(tput setaf 1) ---- Starting Kibana ----"
sudo systemctl restart kibana
sudo systemctl enable kibana
#####################
# Install Filebeat
#####################
echo "$(tput setaf 1) ---- Installing Filebeat ----"
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.0-amd64.deb
sudo dpkg -i filebeat-7.5.0-amd64.deb
sudo rm filebeat*
sudo filebeat modules enable system
sudo filebeat modules enable cisco
sudo filebeat modules enable netflow
sudo filebeat modules enable osquery
sudo filebeat modules enable elasticsearch
sudo filebeat modules enable kibana
sudo filebeat modules enable logstash
echo "$(tput setaf 1) ---- Starting Filebeat ----"
sudo systemctl enable filebeat
sudo systemctl start filebeat
sudo filebeat setup -e
sudo filebeat setup --dashboards
sudo filebeat setup --index-management
sudo filebeat setup --pipelines
#####################
# Install Metricbeat
#####################
echo "$(tput setaf 1) ---- Installing Metricbeat ----"
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.5.0-amd64.deb
sudo dpkg -i metricbeat-7.5.0-amd64.deb
sudo rm metricbeat*
sudo metricbeat modules enable elasticsearch
sudo metricbeat modules enable kibana
sudo metricbeat modules enable logstash
sudo metricbeat modules enable system
echo "$(tput setaf 1) ---- Starting Metricbeat ----"
sudo systemctl enable metricbeat
sudo systemctl start metricbeat
sudo metricbeat setup -e
sudo metricbeat setup --dashboards
sudo metricbeat setup --index-management
sudo metricbeat setup --pipelines
#####################
# Install Packetbeat
#####################
echo "$(tput setaf 1) ---- Installing Packetbeat ----"
sudo apt-get install libpcap0.8
curl -L -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.4.0-amd64.deb
sudo dpkg -i packetbeat-7.4.0-amd64.deb
sudo rm packetbeat*
echo "$(tput setaf 1) ---- Starting Packetbeat ----"
sudo systemctl enable packetbeat
sudo systemctl start packetbeat
sudo packetbeat setup -e
sudo packetbeat setup --dashboards
sudo packetbeat setup --index-management
sudo packetbeat setup --pipelines

#####################
# Install Auditbeat
#####################
echo "$(tput setaf 1) ---- Installing Auditbeat ----"
curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.4.0-amd64.deb
sudo dpkg -i auditbeat-7.4.0-amd64.deb
sudo rm auditbeat*
echo "$(tput setaf 1) ---- Starting Auditbeat ----"
sudo systemctl enable auditbeat
sudo systemctl start auditbeat
sudo auditbeat setup -e
sudo auditbeat setup --dashboards
sudo auditbeat setup --index-management
sudo auditbeat setup --pipelines


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



