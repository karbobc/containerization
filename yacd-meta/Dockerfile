# build static files
ARG NODE_IMAGE
FROM --platform=$BUILDPLATFORM ${NODE_IMAGE:-node:alpine} AS build
ARG YACD_META_VERSION
WORKDIR /app
RUN set -x \
    && apk add --update --no-cache git \
    && git clone https://github.com/MetaCubeX/Yacd-meta.git yacd-meta \
    && cd yacd-meta \
    && [ -z $YACD_META_VERSION ] || git checkout $YACD_META_VERSION \
    && [ -n $YACD_META_VERSION ] || git checkout $(git describe --tags --abbrev=0) \
    && npm install -g pnpm \
    && pnpm install \
    && pnpm build \
    && rm -f public/*.map || true

# nginx server
ARG NGINX_IMAGE
FROM --platform=$TARGETPLATFORM ${NGINX_IMAGE:-nginx:alpine}
RUN set -x \
    && rm -f /etc/nginx/conf.d/* \
    && rm -f /usr/share/nginx/html/*
COPY --from=build /app/yacd-meta/public /usr/share/nginx/html/
COPY --from=build /app/yacd-meta/docker/nginx-default.conf /etc/nginx/conf.d/nginx.conf

CMD ["nginx", "-g", "daemon off;"]