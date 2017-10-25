DIRNAME=$(dirname $0)
BASE_INSTALL=$(cat ${DIRNAME}/BaseInstall.sh)
NGINX_CONFIG=$(cat ${DIRNAME}/../nginx.conf)

SCRIPT_LOCATION="${DIRNAME}/../setup.sh"

cat << EOF > $SCRIPT_LOCATION
$BASE_INSTALL

CURRENT_PID=\$(cat /etc/nginx/nginx.conf | grep -oP "pid\s*\K[^;]*")
PID=\${CURRENT_PID:-/tmp/nginx.pid}

cat << EOL > /etc/nginx/nginx.conf
pid \$PID;
EOL

cat << 'EOL' >> /etc/nginx/nginx.conf
$NGINX_CONFIG
EOL

nginx -s quit || true
nginx
EOF

chmod +x $SCRIPT_LOCATION
