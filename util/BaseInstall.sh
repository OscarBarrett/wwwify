#!/bin/bash

set -e

apt -y update && apt -y upgrade

apt -y install lsb-release
DISTRO=$(lsb_release -is | awk '{print tolower($0)}')
CODENAME=$(lsb_release -cs)

apt -y install curl gnupg
curl -O https://nginx.org/keys/nginx_signing.key && apt-key add ./nginx_signing.key && rm ./nginx_signing.key
echo "deb http://nginx.org/packages/$DISTRO/ $CODENAME nginx" >> /etc/apt/sources.list

apt -y update && apt -y install nginx
