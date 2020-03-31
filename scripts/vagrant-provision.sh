#!/bin/bash

set -e
set -x

# Turn on selinux to be more like production
sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
setenforce 1
setsebool -P httpd_can_network_connect 1

# Add host entry for sandbox.bigfix.com
echo 127.0.0.1 sandbox.bigfix.com >> /etc/hosts

# Add node yum repo
curl -sL https://rpm.nodesource.com/setup_6.x | bash -

# Add epel for nginx
yum install -y epel-release

# Install all the things
yum install -y nginx nodejs rsync gcc-c++ git-all

# Use older version of npm to prevent the following bug:
# https://github.com/npm/npm/issues/14042
npm install -g npm@3.10.7

# Install and start docker
curl -sL https://get.docker.com | bash -
systemctl enable docker
systemctl start docker

# Add the 'vagrant' user to the docker group so that docker doesn't require sudo
usermod -aG docker vagrant

# Setup Makefile that points to the Makefile in the source directory
echo 'SOURCE=/vagrant' >> /home/vagrant/Makefile
echo 'include /vagrant/Makefile' >> /home/vagrant/Makefile

# Start nginx now and forever
systemctl enable nginx.service
systemctl start nginx.service

# Setup nginx
rm /etc/nginx/nginx.conf
make nginx-dev

# Setup the make-dev service
mkdir -p /var/www
rsync -a /vagrant/tools/make-dev /var/www
(cd /var/www/make-dev && npm install)
systemctl is-active --quiet make-dev && systemctl stop make-dev
cp /usr/bin/node /var/www/make-dev/node
cp -f /vagrant/conf/systemd/make-dev.service /usr/lib/systemd/system
systemctl daemon-reload
systemctl enable make-dev
systemctl start make-dev

# Build the site
sudo -H -u vagrant make staging remote-staging
make deploy remote-deploy
