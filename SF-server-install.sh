wget https://bitbucket.org/haiwen/seafile/downloads/seafile-server_4.1.2_x86-64.tar.gz
tar -xvf seafile-server_4.1.2_x86-64.tar.gz
mkdir installed
mv seafile-server_4.1.2_x86-64.tar.gz installed

apt-get update
apt-get install python2.7 python-setuptools python-imaging sqlite3

cd seafile-server-4.1.2
./setup-seafile.sh

apt-get install nginx python-flup

iptables -I INPUT 1 -p tcp --dport 8001 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 8082 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 10001 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 12001 -j ACCEPT

service nginx start

ln -s /etc/nginx/sites-available/example /etc/nginx/sites-enabled/example
rm /etc/nginx/sites-enabled/default
service nginx restart

./seafile.sh start
./seahub.sh start 8001

echo "Remember to work through the guide at http://manual.seafile.com/deploy/deploy_with_nginx.html"

echo "Also make sure that the IP address in the nginx config file is correct"
