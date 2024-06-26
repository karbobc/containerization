# build static files
ARG NODE_IMAGE
FROM --platform=$BUILDPLATFORM ${NODE_IMAGE:-node:16-alpine} AS build
ARG YESPLAYMUSIC_VERSION
ARG VUE_APP_NETEASE_API_URL=/api
ENV VUE_APP_NETEASE_API_URL ${VUE_APP_NETEASE_API_URL}
WORKDIR /app
RUN set -x \
    && apk add --update --no-cache \
       python3 \
       make \
       g++ \
       git \
    && git clone https://github.com/qier222/YesPlayMusic.git yesplaymusic \
    && cd yesplaymusic \
    && [ -n $YESPLAYMUSIC_VERSION ] || git checkout $(git describe --tags --abbrev=0) \
    && [ -z $YESPLAYMUSIC_VERSION ] || git checkout $YESPLAYMUSIC_VERSION \
    && yarn install \
    && yarn build

# s6 overlay
ARG NGINX_IMAGE
FROM --platform=$TARGETPLATFORM ${NGINX_IMAGE:-nginx:alpine}
ARG S6_ARCH
ARG S6_OVERLAY_VERSION
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz /tmp
COPY --from=build /app/yesplaymusic/package.json /usr/local/lib/
RUN set -x \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz \
    && rm -f /tmp/s6-overlay-*.tar.xz \
    && apk add --update --no-cache \
       libuv \
       nodejs \
       npm \
    && npm install -g $(awk -F \" '{if($2=="NeteaseCloudMusicApi") print $2"@"$4}' /usr/local/lib/package.json) \
    && rm -f /usr/local/lib/package.json \
    && rm -f /etc/nginx/conf.d/* \
    && rm -f /usr/share/nginx/html/* \
    && rm -f /var/cache/apk/*
COPY s6-overlay /etc/s6-overlay/s6-rc.d/
COPY ./conf /etc/nginx/conf.d/
COPY --from=build /app/yesplaymusic/dist /usr/share/nginx/html/

ENTRYPOINT ["/init"]