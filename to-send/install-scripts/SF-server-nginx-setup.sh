#!/bin/bash

# ask for ip address
echo "Enter the IP address of the server (the same one earlier in setup)"
read IPADDRESS

# modify existing custom nginx config with settings for current server.
# If there are issues try removing proxy_request_buffering off; as this is a new feature
sed -i "s/SERVERNAMEREPLACETOKEN/$IPADDRESS/g" nginx-config
sed -i "s-http://127.0.0.1:8000-http://$IPADDRESS:8001-g" ~/SeaFileServer/ccnet/ccnet.conf
sed -i "s-http://127.0.0.1/seafhttp-http://$IPADDRESS/seafhttp-g" ~/SeaFileServer/seahub_settings.py

# install nginx
apt-get install python-software-properties
add-apt-repository ppa:nginx/stable
apt-get update && apt-get upgrade
apt-get install nginx nginx-common nginx-full python-flup python-imaging

# open required ports
iptables -I INPUT 1 -p tcp --dport 8001 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 8082 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 10001 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 12001 -j ACCEPT

# copy over config files with correct ip and settings  
cp nginx-config /etc/nginx/sites-available/site
rm ~/SeaFileServer/seafile-data/seafile.conf
cp seafile.conf ~/SeaFileServer/seafile-data/seafile.conf

service nginx start

ln -s /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site
rm /etc/nginx/sites-enabled/default
service nginx restart
