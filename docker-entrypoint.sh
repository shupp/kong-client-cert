#!/usr/local/bin/dumb-init /bin/bash
set -e

# Disabling nginx daemon mode
export KONG_NGINX_DAEMON="off"

# Check for client cert and key
if [ ! -z "$SECRET_CLIENT_KEY" ] && [ ! -z "$SECRET_CLIENT_CERT" ] ; then
    SSL_DIR="/usr/local/kong/ssl"
    if [ ! -d $SSL_DIR ] ; then
        mkdir -p $SSL_DIR
    fi
    echo "$SECRET_CLIENT_KEY" > ${SSL_DIR}/client.key
    echo "$SECRET_CLIENT_CERT" > ${SSL_DIR}/client.crt
    /generate-custom-template.sh > /custom_nginx.lua
    exec "$@" --nginx-conf /custom_nginx.lua
else
    exec "$@"
fi
