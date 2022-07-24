#!/bin/bash

sudo apt update
sudo hostnamectl set-hostname ${master_hostname} --static

wget https://apt.puppet.com/puppet7-release-bullseye.deb
sudo dpkg -i puppet7-release-bullseye.deb
sudo apt update
sudo apt install puppetserver -y

source /etc/profile.d/puppet-agent.sh

sudo sed -i 's/-Xms2g -Xmx2g/-Xms1g -Xmx1g/g' /etc/default/puppetserver

sudo /opt/puppetlabs/bin/puppet resource service puppetserver enable=true

sudo systemctl daemon-reload
sudo systemctl start puppet
sudo systemctl enable puppet


### Configure the puppet master ###
sudo /opt/puppetlabs/bin/puppet config set ca_server ${master_hostname} --section main
sudo /opt/puppetlabs/bin/puppet config set server ${master_hostname} --section main
sudo /opt/puppetlabs/bin/puppet config set dns_alt_names ${master_hostname} --section master
sudo /opt/puppetlabs/bin/puppet config set autosign true --section master
sudo /opt/puppetlabs/bin/puppet config set runinterval 1h --section main
sudo /opt/puppetlabs/bin/puppet config set environment production --section server


sudo systemctl restart puppetserver
