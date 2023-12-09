# build static files
FROM --platform=$BUILDPLATFORM node:alpine AS build
WORKDIR /app
RUN set -x \
    && apk add --no-cache git \
    && git clone https://github.com/MetaCubeX/Yacd-meta yacd-meta \
    && cd yacd-meta \
    && git checkout $(git describe --tags --abbrev=0) \
    && npm install -g pnpm \
    && pnpm install \
    && pnpm build \
    && rm -f public/*.map || true

# nginx server
FROM --platform=$TARGETPLATFORM nginx:alpine
RUN set -x \
    && rm -f /etc/nginx/conf.d/* \
    && rm -f /usr/share/nginx/html/*
COPY --from=build /app/yacd-meta/public /usr/share/nginx/html/
COPY --from=build /app/yacd-meta/docker/nginx-default.conf /etc/nginx/conf.d/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
