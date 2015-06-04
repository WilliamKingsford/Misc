# check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

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

cp nginx-config /etc/nginx/sites-available/site

service nginx start

ln -s /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site
rm /etc/nginx/sites-enabled/default
service nginx restart

echo '"./seafile.sh start" to start seafile'
echo '"./seahub.sh start 8001" to start seahub'
echo "THESE MUST BE RUN AS ROOT"

echo "Remember to work through the guide at http://manual.seafile.com/deploy/deploy_with_nginx.html"

echo "Also make sure that the IP address in the nginx config file is correct"
