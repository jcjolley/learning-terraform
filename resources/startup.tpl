#! /bin/bash

sudo mkdir -p web
cd web

echo "Updating aptget\n" >> terraform.log
sudo apt-get update

echo "installing build tools\n" >> terraform.log
sudo apt-get install -yq build-essential rsync

echo "setting up nodejs repo\n" >> terraform.log
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -

echo "installing node\n" >> terraform.log
sudo apt -y install nodejs

echo "About to create index.html\n" >> terraform.log
echo "<html><body><h1>Host is: ${header}</h1></body></html>" > index.html

echo "Starting server\n" >> terraform.log
nohup sudo npx http-server -p ${port} &
