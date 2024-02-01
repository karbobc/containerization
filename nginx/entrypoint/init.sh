#!/usr/bin/env sh

if [ -z "$DNS_API" ]; then
    echo "DSN_API environment variable must be set!!!"
    exit 1
fi

if [ -z "$DOMAIN" ] || [ -z "$SUB_DOMAINS" ]; then
    echo "DOMAIN or SUB_DOMAINS environment variables must be set!!!"
    exit 1
fi

# crond start
crond -b

# issue CA by DNS
acme.sh --issue \
        --dns $DNS_API \
        -d $DOMAIN \
        $(echo "$SUB_DOMAINS" | awk -v domain="$DOMAIN" -F ',' '{for(i=1;i<=NF;i++) printf " -d "$i"."domain}')

# install CA
set +e
mkdir -p ${NGINX_SSL_PATH:-/etc/nginx/ssl}
acme.sh --install-cert \
        -d $DOMAIN \
        --key-file       ${NGINX_SSL_PATH:-/etc/nginx/ssl}/key.pem \
        --fullchain-file ${NGINX_SSL_PATH:-/etc/nginx/ssl}/cert.pem \
        --reloadcmd      "nginx -s reload"
set -e