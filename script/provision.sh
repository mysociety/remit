#!/usr/bin/env bash

set -e

export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# We need a new repo to get elasticsearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/0.90/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-0.90.list

sudo apt-get update
sudo apt-get install -y curl git openjdk-6-jre libpq-dev postgresql imagemagick
sudo apt-get install elasticsearch=0.90.3

# Make elastic search run at startup
sudo update-rc.d elasticsearch defaults

#install rvm
# TODO: Needs Jones truncation armour, currently fails if used: http://drj11.wordpress.com/2014/03/19/piping-into-shell-may-be-harmful/

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source .bash_profile

rvm install 1.9.3-p551

# Create a database user
echo "CREATE ROLE remit WITH PASSWORD 'password' CREATEDB LOGIN" | sudo -u postgres psql


# Install site deps
cd /vagrant
bundle install

# Setup the site config files
# cp config/carrierwave.yml-example config/carrierwave.yml
# cp config/exception_notification.yml-example config/exception_notification.yml
cp config/database.yml-example config/database.yml
cp config/secrets.yml-example config/secrets.yml
cp config/general.yml-example config/general.yml

# Add the tables and seed data into the db
rake db:setup

echo "ReMIT installed successfully!"
echo "To start the server: vagrant ssh, cd /vagrant, rails s -b 0.0.0.0, the server will then run at http://localhost:3000/"
