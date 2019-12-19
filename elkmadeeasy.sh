#!/bin/bash
#
# Author:
#
###################################################

echo "---------------------------------------------------------------" 
echo " $(date)"
echo " Starting ELK Made Easy "
echo " ELK Stack for Debian-based Systems and Redhat-based Systems "
echo " Elasticsearch - Logstash - Kibana - Metricbeat"
echo "---------------------------------------------------------------"
echo " easyELK Status "
echo ""
echo " System Update... "

# Checking whether user has enough permission to run this script
sudo -n true
if [ $? -ne 0 ]
    then
        echo "This script requires user to have passwordless sudo access"
        exit
fi

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        # Installing Java 8 if it's not installed
        sudo apt-get install openjdk-8-jre-headless -y
    # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
    elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
        then
            sudo apt-get install openjdk-8-jre-headless -y
fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            #Installing Java 8 if it's not installed
            sudo yum install jre-1.8.0-openjdk -y
        # Checking if java installed is less than version 7. If yes, installing Java 8. As logstash & Elasticsearch require Java 7 or later.
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                sudo yum install jre-1.8.0-openjdk -y
    fi
}

##############################################################
# Install ElasticSearch, Logstash, and Kibana on Debian/Ubuntu
##############################################################

debian_elk() {
    # resynchronize the package index files from their sources.
    sudo apt-get update 
    sudo apt-get upgrade
    
    # Downloading debian package of logstash
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-7.5.0.deb
    
    # Install logstash debian package
    echo "$(tput setaf 1) ---- Installing Logstash ----"
    sudo dpkg -i /opt/logstash-7.5.0.deb
    
    # Downloading debian package of elasticsearch
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.0.deb
    
    # Install debian package of elasticsearch
    echo "$(tput setaf 1) ---- Installing the Elasticsearch Debian Package ----"
    sudo dpkg -i /opt/elasticsearch-7.5.0.deb
    
    # Install kibana
    echo "$(tput setaf 1) ---- Installing the Kibana Debian Package ----"
    sudo apt-get install curl apt-transport-https software-properties-common lsb-release gnupg2 dirmngr sudo expect net-tools -y
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-7.5.0-amd64.deb
    sudo dpkg -i /opt/kibana-7.5.0-amd64.deb
    
    # Install Filebeat
    echo "$(tput setaf 1) ---- Installing Filebeat ----"
    curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb
    sudo dpkg -i filebeat-7.5.0-amd64.deb
    sudo rm filebeat*
    sudo filebeat modules enable system
    sudo filebeat modules enable cisco
    sudo filebeat modules enable netflow
    sudo filebeat modules enable osquery
    sudo filebeat modules enable elasticsearch
    sudo filebeat modules enable kibana
    sudo filebeat modules enable logstash
    
    # Install Metricbeat
    echo "$(tput setaf 1) ---- Installing Metricbeat ----"
    curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.4.0-amd64.deb
    sudo dpkg -i metricbeat-7.4.0-amd64.deb
    sudo rm metricbeat*
    sudo metricbeat modules enable elasticsearch
    sudo metricbeat modules enable kibana
    sudo metricbeat modules enable logstash
    sudo metricbeat modules enable system
   
   # Install Packetbeat
    echo "$(tput setaf 1) ---- Installing Packetbeat ----"
    sudo apt-get install libpcap0.8
    curl -L -O https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.4.0-amd64.deb
    sudo dpkg -i packetbeat-7.4.0-amd64.deb
    sudo rm packetbeat*
    
    # Install
    echo "$(tput setaf 1) ---- Installing Auditbeat ----"
    curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.4.0-amd64.deb
    sudo dpkg -i auditbeat-7.4.0-amd64.deb
    sudo rm auditbeat*
    
    echo "$(tput setaf 1) ---- Starting Elasticsearch ----"
    sudo systemctl restart elasticsearch
    sudo systemctl enable elasticsearch
    
    echo "$(tput setaf 1) ---- Starting Kibana ----"
    sudo systemctl restart kibana
    sudo systemctl enable kibana
    
    echo "$(tput setaf 1) ---- Starting Logstash ----"
    sudo systemctl restart logstash
    sudo systemctl enable logstash    
    
    echo "$(tput setaf 1) ---- Starting Filebeat ----"
    sudo systemctl enable filebeat
    sudo systemctl start filebeat
    sudo filebeat setup -e
    sudo filebeat setup --dashboards
    sudo filebeat setup --index-management
    sudo filebeat setup --pipelines

    echo "$(tput setaf 1) ---- Starting Metricbeat ----"
    sudo systemctl enable metricbeat
    sudo systemctl start metricbeat
    sudo metricbeat setup -e
    sudo metricbeat setup --dashboards
    sudo metricbeat setup --index-management
    sudo metricbeat setup --pipelines

    echo "$(tput setaf 1) ---- Starting Packetbeat ----"
    sudo systemctl enable packetbeat
    sudo systemctl start packetbeat
    sudo packetbeat setup -e
    sudo packetbeat setup --dashboards
    sudo packetbeat setup --index-management
    sudo packetbeat setup --pipelines

    echo "$(tput setaf 1) ---- Starting Auditbeat ----"
    sudo systemctl enable auditbeat
    sudo systemctl start auditbeat
    sudo auditbeat setup -e
    sudo auditbeat setup --dashboards
    sudo auditbeat setup --index-management
    sudo auditbeat setup --pipelines
}

##############################################################
# Install ElasticSearch, Logstash, and Kibana on RedHat/Centos
##############################################################

#rpm_elk() {
#    #Installing wget.
#    sudo yum install wget -y
#    # Downloading rpm package of logstash
#    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-7.5.0.rpm
#    # Install logstash rpm package
#    sudo rpm -ivh /opt/logstash-7.5.0.rpm
#    
#    #Downloading rpm package of elasticsearch
#    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.0.rpm
#    # Install rpm package of elasticsearch
#    sudo rpm -ivh /opt/elasticsearch-7.5.0.rpm
#   
#    # Download kibana tarball in /opt
#    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-7.5.0-linux-x86_64.tar.gz
#    # Extracting kibana tarball
#    sudo tar zxf /opt/kibana-7.5.0-linux-x86_64.tar.gz -C /opt/
#
#    # Starting The Services
#    sudo service logstash start
#    sudo service elasticsearch start
#    sudo /opt/kibana-7.5.0-linux-x86_64/bin/kibana &
#}

# Installing ELK Stack
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
    then
        echo " It's a Debian based system"
        dependency_check_deb
        debian_elk
        
        
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "It's a RedHat based system."
        dependency_check_rpm
        rpm_elk
else
    echo "This script doesn't support ELK installation on this OS."
fi

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




 
 
