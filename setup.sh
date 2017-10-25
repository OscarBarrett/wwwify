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

CURRENT_PID=$(cat /etc/nginx/nginx.conf | grep -oP "pid\s*\K[^;]*")
PID=${CURRENT_PID:-/tmp/nginx.pid}

cat << EOL > /etc/nginx/nginx.conf
pid $PID;
EOL

cat << 'EOL' >> /etc/nginx/nginx.conf
user nginx;

worker_processes 1;
worker_rlimit_nofile 32384;

events {
  worker_connections 4096;

  multi_accept on;
  use epoll;
}

http {
  error_log off;
  access_log off;

  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;

  keepalive_timeout 5;
  reset_timedout_connection on;

  server {
    listen 80;

    if ($host ~* ^(?!www\.).*$) {
      return 301 http://www.$host$request_uri;
    }

    return 400;
  }
}

stream {
  resolver 8.8.8.8;
  resolver_timeout 5s;

  server {
    listen 443;

    ssl_preread on;

    proxy_pass www.$ssl_preread_server_name:443;
  }
}
EOL

nginx -s quit || true
nginx
