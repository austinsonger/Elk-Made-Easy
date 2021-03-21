#! /bin/bash
# Email : austin@songer.pro
# Website : https://songer.pro
# ELK Made Easy
# ------------------------------#
# UBUNTU 18.04, 20.04
# ------------------------------#

clear
echo -e "[>>] ----------------------------------------------------------- [<<]"
echo -e "[>>] Website : https://songer.pro                                [<<]"
echo -e "[>>] Github : https://github.com/austinsonger                    [<<]"
echo -e "[>>] Email : austin@songer.pro                                   [<<]"
echo -e "[>>] ----------------------------------------------------------- [<<]"
echo -e "[>>] ELK Made Easy                                               [<<]"
echo -e "[>>] Tested on UBUNTU 18.04, 20.04                               [<<]"
echo -e "[>>] ----------------------------------------------------------- [<<]"

sudo -n true
sudo apt update -y
sudo apt list --upgradable -a
sudo apt upgrade -y
sudo dpkg --configure -a
sudo apt install -f
sudo apt update --fix-missing
sudo apt --fix-broken install -y
apt -y -f install
apt clean
apt install net-tools
apt install -y lsb-release &> /dev/null
CHECK lsb_release 
which lsb_release &> /dev/null
[ "$?" != "0" ] && echo -e "\e[91m[>] Can't find lsb_release COMMAND\e[0m" && exit !
lsb_release -cs | grep 'focal' &> /dev/null
[ "$?" != "0" ] && echo -e "\e[91m[>] Can't Install Netdata In Your OS\e[0m"
apt install wget apt-transport-https curl gpgv gpgsm gnupg-l10n gnupg dirmngr ca-certificates nginx software-properties-common apache2-utils jq -y
sudo add-apt-repository universe
sleep 10


## JAVA 
# openjdk-11-jdk
sudo apt -y install openjdk-11-jdk
# sudo echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
# source /etc/environment
# sudo apt install default-jre default-jdk -y
# update-alternatives --config java
# export JAVA_HOME=/usr/lib/jvm/default-java-
# export PATH=${PATH}:${JAVA_HOME}/bin
sleep 5

## Elasticsearch ##
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update
apt-get install elasticsearch -y
systemctl stop elasticsearch
systemctl enable elasticsearch
cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.$RANDOM.backup
echo 'transport.host: localhost' >> /etc/elasticsearch/elasticsearch.yml
echo 'transport.tcp.port: 9300' >> /etc/elasticsearch/elasticsearch.yml
echo 'network.host: localhost' >> /etc/elasticsearch/elasticsearch.yml
echo 'http.port: 9200' >> /etc/elasticsearch/elasticsearch.yml
echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
echo 'setup.ilm.overwrite: true' >> /etc/elasticsearch/elasticsearch.yml
echo '-Xms512m' >> /etc/elasticsearch/jvm.options
echo '-Xmx512m' >> /etc/elasticsearch/jvm.options
systemctl daemon-reload
systemctl start elasticsearch
sleep 25
systemctl restart elasticsearch
echo RESTARTING Elasticsearch.......
sleep 60


## Kibana ##
sudo apt install kibana -y
systemctl stop kibana
systemctl enable kibana
cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.$RANDOM.backup
echo -e "server.port: 5601" >> /etc/kibana/kibana.yml
echo -e "server.host: $HOSTNAME" >> /etc/kibana/kibana.yml
echo -e 'elasticsearch.hosts: ["http://localhost:9200"]' >> /etc/kibana/kibana.yml
echo -e 'elasticsearch.username: "elastic"' >> /etc/kibana/kibana.yml
echo -e 'elasticsearch.password: "ChangePassword1!"' >> /etc/kibana/kibana.yml
systemctl daemon-reload
systemctl start kibana
sleep 10


## Logstash ##
# INSTALL LOGSTASH PACKAGE 
sudo apt install logstash -y
sleep 10
systemctl daemon-reload
systemctl stop logstash
systemctl enable logstash
systemctl start logstash
sleep 10

## Filebeat ##
# INSTALL FILEBEAT PACKAGE 
sudo apt install filebeat -y
cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.$RANDOM.backup
sed -i 's/^output.elasticsearch/$output.elasticsearch/g' /etc/filebeat/filebeat.yml
sed -i 's/hosts: \["127.0.0.1:9200"\]/#hosts: \["127.0.0.1:9200"\]/g' /etc/filebeat/filebeat.yml
echo -e "output.logstash:" >> /etc/filebeat/filebeat.yml
echo -e "hosts: [\"127.0.0.1:5044\"]" >> /etc/filebeat/filebeat.yml
filebeat modules enable system
filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["127.0.0.1:9200"]'
systemctl start filebeat
systemctl daemon-reload
sleep 10

## Prevent Updates ##
sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/elastic-7.x.list
apt-get update


### Nginx### Nginx
# echo "admin:$(openssl passwd -apr1)" | tee -a /etc/nginx/htpasswd.users
# echo -e "You need to set a username and password to login."
# read -p "Please enter a username : " user
# htpasswd -c /etc/nginx/conf.d/kibana.htpasswd $user
# cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.$RANDOM.backup
# touch /etc/nginx/sites-available/default
# cat > /etc/nginx/sites-available/default <<\EOF
# server {
#     listen 80;
#      server_name $HOSTNAME;
#     auth_basic "Restricted Access";
#     auth_basic_user_file /etc/nginx/htpasswd.users;
#     location / {
#         proxy_pass http://127.0.0.1:5601;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade \$http_upgrade;
#         proxy_set_header Connection 'upgrade';
#         proxy_set_header Host \$host;
#         proxy_cache_bypass \$http_upgrade;
#     }
# }
# EOF

# nginx -t
# systemctl start nginx

# Remove old package lists #
############################
rm -rf /var/lib/apt/lists/*

# Clean #
#########
sudo apt autoremove --purge -y
sudo apt autoclean -y
sudo rm -rf /home/$USER/.local/share/Trash/*
sudo find /tmp/ -type f -mtime +1 -exec sudo rm {} \;
sudo find /tmp/ -type f -atime +1 -exec sudo rm {} \;
sudo apt remove -y
sudo apt clean -y
sudo apt clean all -y

read -p "Press [Enter] to exit."
