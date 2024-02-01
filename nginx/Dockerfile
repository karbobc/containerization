
# image arguments
ARG NGINX_IMAGE=nginx:alpine

# base image
FROM --platform=$TARGETPLATFORM ${NGINX_IMAGE}

# maintainer
LABEL maintainer="Karbob <karbobc@gmail.com>"

# arguments and default value
ARG NGINX_SCRIPTS_PATH=/etc/nginx/scripts
ARG NGINX_HTTP_CONF_PATH=/etc/nginx/conf.d/http
ARG NGINX_STREAM_CONF_PATH=/etc/nginx/conf.d/stream
ARG NGINX_SSL_PATH=/etc/nginx/ssl
ARG NGINX_LOGS_PATH=/etc/nginx/logs
ARG LE_AUTO_UPGRADE=0
ARG LE_DEFAULT_CA=letsencrypt
ARG LE_WORKING_DIR=/acme.sh
ARG LE_CONFIG_HOME=${LE_WORKING_DIR}/conf
ARG LE_LOGS_PATH=${LE_WORKING_DIR}/logs

# environment's variables
ENV AUTO_UPGRADE ${LE_AUTO_UPGRADE}
ENV LE_WORKING_DIR ${LE_WORKING_DIR}
ENV LE_CONFIG_HOME ${LE_CONFIG_HOME}
ENV NGINX_SSL_PATH ${NGINX_SSL_PATH}

# copy files from host
COPY ./scripts ${NGINX_SCRIPTS_PATH}/
COPY ./entrypoint /docker-entrypoint.d/entrypoint/

RUN set -x \
# install acme.sh
    && apk update \
    && apk add --no-cache \
       openssl \
       openssh-client \
       coreutils \
       bind-tools \
       socat \
       tzdata \
       oath-toolkit-oathtool \
       libidn \
       jq \
    && apk add --no-cache --virtual .build-deps \
       git \
    && mkdir -p ${LE_WORKING_DIR} ${LE_LOGS_PATH} \
    && git clone https://github.com/acmesh-official/acme.sh /install_acme.sh \
    && cd /install_acme.sh \
    && ./acme.sh --install \
       --home ${LE_WORKING_DIR} \
       --config-home ${LE_CONFIG_HOME} \
       --log ${LE_LOGS_PATH}/acme.sh.log \
    && cd / \
    && rm -rf /install_acme.sh \
    && ln -sf ${LE_WORKING_DIR}/acme.sh /usr/local/bin/acme.sh \
# logging to file
    && crontab -l | grep acme.sh | sed 's,> /dev/null,,' | crontab - \
# set default CA server to letsencrypt
    && acme.sh --set-default-ca --server ${LE_DEFAULT_CA} \
# nginx config
    && rm -f /etc/nginx/conf.d/* \
    && sed -i '/worker_connections\s\+[0-9]\+/s/[0-9]\+/10240/' /etc/nginx/nginx.conf \
    && sed -i "/include.*conf;\$/s_/.*;\$_${NGINX_HTTP_CONF_PATH}/*.conf;_" /etc/nginx/nginx.conf \
    && echo -e "\nstream {\n    include ${NGINX_STREAM_CONF_PATH}/*.conf;\n}\n" >> /etc/nginx/nginx.conf \
    && sed -i "s_/var/log/nginx_${NGINX_LOGS_PATH}_" /etc/nginx/nginx.conf \
    && sed -i '/log_format.*/s/time_local/time_iso8601/' /etc/nginx/nginx.conf\
    && { crontab -l; echo "0 2 * * * ${NGINX_SCRIPTS_PATH}/slicelog.sh > /dev/null"; } | crontab - \
    && apk del --purge .build-deps \
    && rm -f /var/cache/apk/*

EXPOSE 80 443

# run nginx in non deamon
CMD ["nginx", "-g", "daemon off;"]