#!/bin/bash -ex

# Install some packages
yum -y update --security
yum -y install wget
yum -y install ruby
yum -y install git
yum -y install vim
yum -y install htop
yum -y install nginx

# Setup some google-admin specific stuff
useradd -c "google-admin Role Account" google-admin

# Install public keys in ec2-user
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxfHZpxkTa8odsxnda19sV+CG32ZspkLKh2CtOGS1C+/l0XTEc2YFn8nWA0I7FaXuin9XBjtkyN92PTrHtGWHidtmKwpC81nYy7zsSPc5WQ+Ghx2sJhcxh8vhsQV4vkKe2fD75BOwbBABQPatwP5cwtOmb8xO2jrCLnmK8KrU73r0+dFJC7uBC/SvKCU4kNQdnT6LVa1q21rQEjiCAijJbpmkzY2nw8QwL3DLvrMOjy6hAjmo2DYBFWx9lppWc/M8lEYmOP/kbNAxiuiR1Yihog1bYcZfR1pxY6YrF32yr98fwIoYi2ALmZ7P1Q6j3SRMFarL abhin@USBUR1VWB151874" >> /home/ec2-user/.ssh/authorized_keys

mkdir /opt/google-admin
mkdir /opt/google-admin/log
chown -R google-admin:google-admin /opt/google-admin

# Set Hostname
DOMAIN=aws.google.com
IPV4=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
HOSTNAME=`echo google-admin-$${INSTANCE_ID}`

if [ -f /etc/system-release ];then
   echo "Setting Hostname on Amazon System"
   hostname $${HOSTNAME}
   # Add fqdn to hosts file
cat<<EOF > /etc/hosts
# This file is automatically genreated by ec2 cloud init script
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
$${IPV4} $${HOSTNAME}.$${DOMAIN} $${HOSTNAME}
::1         localhost6 localhost6.localdomain6
EOF
else
   echo "System not recognized!"
fi

#useradd -c "Nginx role account" nginx

mkdir -p /var/www/google-admin

chown google-admin:google-admin /var/www/google-admin

mv /etc/nginx/nginx.conf /etc/nginx/nginx.confORIG

cat<<EOF2 > /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    server_tokens       off;
    proxy_connect_timeout   60;
    proxy_send_timeout      60;
    proxy_read_timeout      60;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    index   index.html index.htm;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header 'Access-Control-Allow-Origin' "\$http_origin" always;
}
EOF2

cd /etc/nginx/conf.d
wget https://s3-us-west-2.amazonaws.com/google-admin-build-repo/conf.d/reverse-proxy.conf

mkdir /etc/nginx/ssl

cd /etc/nginx/ssl
## Copy certificate
wget https://s3-us-west-2.amazonaws.com/google-admin/certs/server.crt
wget https://s3-us-west-2.amazonaws.com/google-admin/certs/server.key

chmod 400 /etc/nginx/ssl/*

chkconfig nginx on
service nginx start



# Install nodejs  12
wget https://rpm.nodesource.com/setup_12.x
chmod 750 setup_12.x
/bin/bash setup_12.x
#curl --silent --location https://rpm.nodesource.com/setup_12.x | bash -
yum -y install nodejs
npm install -g n
n 12
# Install pm2 too
npm install pm2 -g
# Install yarn
npm install -g yarn
# Have pm2 create the setup script
pm2 startup systemv -u google-admin --hp /home/google-admin



cat  > /etc/logrotate.d/google-admin <<EOF
/opt/google-admin/log/*log {
    prerotate
        sleep $[ ( $RANDOM % 30 )  + 1 ]s
    endscript
    create 0660 google-admin google-admin
    daily
    size 2048M
    rotate 2
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
    su - google-admin -c "/usr/bin/pm2 reloadLogs google-admin-api"
    endscript
}
EOF

#Fixing the reboot problem for google-admin API
echo "## DO NOT Change - Maintained by User-Data ##" > /etc/cron.d/reboot && echo "@reboot google-admin /opt/google-admin/app/codedeploy/start_server.sh" >> /etc/cron.d/reboot
