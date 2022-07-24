#!/bin/bash

sudo apt update
sudo hostnamectl set-hostname ${agent_hostname} --static

wget https://apt.puppet.com/puppet7-release-bullseye.deb
sudo dpkg -i puppet7-release-bullseye.deb
sudo apt update
sudo apt install puppet-agent

sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

source /etc/profile.d/puppet-agent.sh

sudo /opt/puppetlabs/bin/puppet config set server ${master_hostname} --section agent
sudo /opt/puppetlabs/bin/puppet config set ca_server ${master_hostname} --section agent

sudo systemctl restart puppet
sudo systemctl status puppet


#sudo /opt/puppetlabs/bin/puppet ssl bootstrap
sudo /opt/puppetlabs/bin/puppet agent -t
